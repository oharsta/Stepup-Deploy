Feature: A RAA manages tokens tokens registered in the selfservice portal
  In order to manage tokens
  As a RAA
  I must be able to manage second factor tokens from my institution

  Scenario: RA user can't vet a token from another institution it is not RA for
    Given a user "Jane Toppan" identified by "urn:collab:person:institution-a.example.com:jane-a-ra" from institution "institution-a.example.com"
      And the user "urn:collab:person:institution-a.example.com:jane-a-ra" has a vetted "yubikey"
      And the user "urn:collab:person:institution-a.example.com:jane-a-ra" has the role "ra"
      And a user "Joe Satriani" identified by "urn:collab:person:institution-d.example.com:joe-d1" from institution "institution-d.example.com"
      And the user "urn:collab:person:institution-d.example.com:joe-d1" has a verified "yubikey" with registration code "1234ABCD"
      And a user "Joe Perry" identified by "urn:collab:person:institution-e.example.com:joe-e1" from institution "institution-e.example.com"
      And the user "urn:collab:person:institution-e.example.com:joe-e1" has a verified "yubikey" with registration code "9876WXYZ"
      And I have the payload
        """
        {
          "institution-a.example.com": {
            "use_ra_locations": true,
            "show_raa_contact_information": true,
            "verify_email": true,
            "allowed_second_factors": [],
            "number_of_tokens_per_identity": 2,
            "use_ra": ["institution-a.example.com", "institution-d.example.com"]
          }
        }
        """
      And I authenticate to the Middleware API
      And I request "POST /management/institution-configuration"
      And I am logged in into the ra portal as "jane-a-ra" with a "yubikey" token
     When I search for "9876WXYZ" on the token activation page
     Then I should see "Unknown activation code"

  Scenario: RA user can view token overview and sees tokens from other institutions
    Given I am logged in into the ra portal as "jane-a-ra" with a "yubikey" token
     When I visit the Tokens page
     Then I should see "institution-a.example.com" in the search results
      And I should see "institution-d.example.com" in the search results

  Scenario: RA user can filter the token overview
    Given I am logged in into the ra portal as "jane-a-ra" with a "yubikey" token
     When I visit the Tokens page
      And I filter the "Institution" filter on "institution-d.example.com"
      And I should see "institution-d.example.com" in the search results
     Then I should not see "institution-a.example.com" in the search results

  Scenario: RA user can vet a token from another institution it is RA for
    Given I am logged in into the ra portal as "jane-a-ra" with a "yubikey" token
     When I search for "1234ABCD" on the token activation page
     Then I should see "Please connect the user's personal Yubikey with your computer"

  Scenario: SRAA user promotes "jane-a1" to be an RA
    Given I am logged in into the ra portal as "admin" with a "yubikey" token
     When I switch to institution "institution-a.example.com"
      And I visit the RA Management RA promotion page
     Then I change the role of "jane-a1" to become RA

  Scenario: SRAA user demotes "jane-a1" to no longer be an RA
    Given I am logged in into the ra portal as "admin" with a "yubikey" token
     When I switch to institution "institution-a.example.com"
      And I visit the RA Management page
     Then I relieve "jane-a1" of his RA role

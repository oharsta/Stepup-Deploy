Feature: A SRAA is the Super RAA and is a more privileged user
  In order to efficiently vet tokens
  As a SRAA
  I must be able to manage second factor tokens, switch between institutions and perform other RA tasks

  Scenario: The SRAA user can vet tokens it is not FGA configured for
    Given a user "Jane Toppan" identified by "urn:collab:person:institution-a.example.com:jane-a-ra" from institution "institution-a.example.com"
    Given a user "Joe Toppan" identified by "urn:collab:person:institution-a.example.com:joe-a1" from institution "institution-a.example.com"
      And the user "urn:collab:person:institution-a.example.com:jane-a-ra" has a vetted "yubikey"
      And the user "urn:collab:person:institution-a.example.com:joe-a1" has a vetted "yubikey"
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
          },
          "stepup.example.com": {
            "use_ra_locations": true,
            "show_raa_contact_information": true,
            "verify_email": true,
            "allowed_second_factors": [],
            "number_of_tokens_per_identity": 2
          }
        }
        """
      And I authenticate to the Middleware API
      And I request "POST /management/institution-configuration"
      And I am logged in into the ra portal as "admin" with a "yubikey" token
     When I search for "9876WXYZ" on the token activation page
     Then I should see "Please connect the user's personal Yubikey with your computer"

# Scenario: The SRAA user can switch between institutions with the institution switcher

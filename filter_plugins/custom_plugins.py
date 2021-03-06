#
# Usage: {{ foo | vault(path to keystore) }}
#        {{ foo | sha256 }}
#        {{ foo | depem }}

# vault: decrypt string using key stored in keyczar vault.
# sha256: return hex encoded SHA-256 hash of string
# depem: Strip PEM headers and remove all whitespace from string

def vault(encrypted, keydir):
  #keydir = "~/.stepup-ansible-keystore"
  method = """
from keyczar import keyczar
import os.path
import sys

expanded_keydir = os.path.expanduser("%s")
crypter = keyczar.Crypter.Read(expanded_keydir)
sys.stdout.write(crypter.Decrypt("%s"))
  """ % (keydir, encrypted)
  from subprocess import check_output
  return check_output(["python", "-c", method])


def sha256s(data):
  import hashlib
  return hashlib.sha256(data).hexdigest()


def depem(string):
  import re
  return re.sub(r'\s+|(-----(BEGIN|END).*-----)', '', string)


class FilterModule(object):

  def filters(self):
    return {
      'vault': vault,

      'sha256': sha256s,

      'depem': depem,
    }

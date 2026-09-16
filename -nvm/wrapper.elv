use os
use str
use ./paths
use github.com/giancosta86/ethereal/v1/command

fn -ensure-installed {
  if (os:exists $paths:nvm-script) {
    return
  }

  echo 📥 Installing nvm...

  var nvm-setup-command = 'wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash'

  command:silence {
    bash -c $nvm-setup-command
  }

  echo 🚀 nvm ready!
}

#
# Wraps the Bash script for nvm - forwarding all of its arguments and emitting its output;
# if the "nvm.sh" script does not exist, installs nvm first.
#
fn nvm { |@arguments|
  -ensure-installed

  str:join ' ' $arguments |
    put "source '"$paths:nvm-script"' && nvm "(all) |
    command:update-env-via-bash [PATH NVM_BIN NVM_INC]
}

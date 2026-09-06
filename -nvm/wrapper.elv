use str
use ./paths
use github.com/giancosta86/ethereal/v1/command

#
# Wraps the Bash script for nvm - forwarding all of its arguments and emitting its output.
#
fn nvm { |@arguments|
  str:join ' ' $arguments |
    put "source '"$paths:nvm-script"' && nvm "(all) |
    command:update-env-via-bash [PATH NVM_BIN NVM_INC]
}

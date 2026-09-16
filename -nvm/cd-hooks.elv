use os
use github.com/giancosta86/ethereal/v1/elvish/cd-hooks
use ../nodejs/requested-version
use ./wrapper

fn -after-cd {
  var requested-node-version = (requested-version:detect-recursively $pwd)

  if $requested-node-version {
    var current-node-version = (wrapper:nvm current)

    if (not-eq $current-node-version $requested-node-version) {
      wrapper:nvm install --no-progress $requested-node-version
    }
  }
}

fn -run-nvm-to-update-env-vars {
  wrapper:nvm --version > $os:dev-null 2>&1
}

#
# Registers the `cd` Elvish hooks ensuring that the requested NodeJS version - via .nvmrc or package.json - is being used by nvm; additionally, the hook is run on the current directory.
#
fn register {
  -run-nvm-to-update-env-vars

  cd-hooks:register [
    &after=$-after-cd~
  ]
}

#
# Initializes the environment variables and invokes the after-cd hook without registering it.
#
# Especially suitable for CI/CD contexts.
#
fn setup-env {
  -run-nvm-to-update-env-vars

  -after-cd
}
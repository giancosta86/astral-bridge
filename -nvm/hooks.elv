use os
use ../nodejs/requested-version
use ./wrapper

var -latest-dir = $nil

fn -after-chdir-hook { |_|
  if (eq $pwd $-latest-dir) {
    return
  }

  set -latest-dir = $pwd

  try {
    var requested-node-version = (requested-version:detect-recursively $pwd)

    if $requested-node-version {
      var current-node-version = (wrapper:nvm current)

      if (not-eq $current-node-version $requested-node-version) {
        wrapper:nvm install --no-progress $requested-node-version
      }
    }
  } catch e {
    show $e
  }
}

fn -run-nvm-to-update-env-vars {
  wrapper:nvm --version > $os:dev-null 2>&1
}

#
# Registers the `chdir` Elvish hooks ensuring that the requested NodeJS version - via .nvmrc or package.json - is being used by nvm; additionally, the hook is run on the current directory.
#
fn register-chdir-hooks {
  set after-chdir = (conj $after-chdir $-after-chdir-hook~)

  -run-nvm-to-update-env-vars

  -after-chdir-hook $pwd
}
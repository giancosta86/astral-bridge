use ../version/requested
use ./wrapper

fn -use-requested-node-version { |path|
  var requested-node-version = (requested:detect-recursively $path)

  if $requested-node-version {
    var current-node-version = (wrapper:get-current-node-version)

    if (not-eq $current-node-version $requested-node-version) {
      wrapper:nvm install --no-progress $requested-node-version
    }
  }
}

#
# Registers the `after-chdir` Elvish hook ensuring that the requested NodeJS version - via .nvmrc or package.json - is being used by nvm; additionally, the hook is run on the current directory.
#
fn register-after-chdir {
  set after-chdir = (conj $after-chdir $-use-requested-node-version~)

  -use-requested-node-version $pwd
}
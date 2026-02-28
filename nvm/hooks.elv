use github.com/giancosta86/ethereal/v1/lang
use ../version/requested
use ./wrapper
use ./paths

fn -use-requested-node-version { |path|
  var requested-node-version = (requested:detect-recursively $path)

  if $requested-node-version {
    var current-node-version = (wrapper:nvm current | lang:ensure-put)

    if (not-eq $current-node-version $requested-node-version) {
      wrapper:nvm install --no-progress $requested-node-version

      paths:ensure-current
    }
  }
}

#
# Registers the **after-chdir** hook ensuring that the requested NodeJS version is being used by nvm;
# additionally, the hook is run on the current directory.
#
fn register-after-chdir {
  set after-chdir = (conj $after-chdir $-use-requested-node-version~)

  -use-requested-node-version $pwd
}
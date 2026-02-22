use github.com/giancosta86/ethereal/v1/lang
use ../version
use ./bridge
use ./paths

fn after-chdir { |path|
  var requested-node-version = (version:detect-recursively $path)

  if $requested-node-version {
    var current-node-version = (bridge:nvm current | lang:ensure-put)

    if (not-eq $current-node-version $requested-node-version) {
      bridge:nvm install $requested-node-version

      paths:ensure-current-nodejs
    }
  }
}
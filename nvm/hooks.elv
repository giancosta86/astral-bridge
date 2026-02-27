use github.com/giancosta86/ethereal/v1/lang
use ../version/requested
use ./wrapper
use ./paths

fn -use-requested-nodejs-version { |path|
  var requested-node-version = (requested:detect-recursively $path)

  if $requested-node-version {
    var current-node-version = (wrapper:nvm current | lang:ensure-put)

    if (not-eq $current-node-version $requested-node-version) {
      wrapper:nvm install $requested-node-version

      paths:ensure-current-nodejs
    }
  }
}

fn register-after-chdir {
  set after-chdir = (conj $after-chdir $-use-requested-nodejs-version~)

  -use-requested-nodejs-version $pwd
}
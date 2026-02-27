use path
use str
use github.com/giancosta86/ethereal/v1/lang

var nvm-home = (path:join ~ .nvm)

var bash-script = (path:join $nvm-home nvm.sh)

var downloaded-nodejs-root = (path:join $nvm-home versions)

fn is-not-downloaded-nodejs-bin { |@arguments|
  var path = (lang:get-single-input $arguments)

  str:has-prefix $path $downloaded-nodejs-root''$path:separator |
    not (all)
}

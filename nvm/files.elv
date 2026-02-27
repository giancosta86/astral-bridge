use path
use str
use github.com/giancosta86/ethereal/v1/lang

var nvm-home = (path:join ~ .nvm)

var bash-script = (path:join $nvm-home nvm.sh)

var downloaded-node-root = (path:join $nvm-home versions)

#
# Returns $true if the given path is **not** in the directory of nvm-downloaded NodeJS versions.
#
fn is-not-downloaded-node { |@arguments|
  var path = (lang:get-single-input $arguments)

  str:has-prefix $path $downloaded-node-root''$path:separator |
    not (all)
}

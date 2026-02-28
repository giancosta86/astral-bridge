use path
use str
use github.com/giancosta86/ethereal/v1/lang

var nvm-home = (path:join ~ .nvm)

var bash-script = (path:join $nvm-home nvm.sh)

var download-root = (path:join $nvm-home versions)

var download-node-root = (path:join $download-root node)

#
# Returns $true if the given path is **not** in the directory of nvm-downloaded software, $false otherwise.
#
fn is-not-downloaded { |@arguments|
  var path = (lang:get-single-input $arguments)

  str:has-prefix $path $download-root''$path:separator |
    not (all)
}

use path
use github.com/giancosta86/ethereal/v1/lang
use ./files

#
# Emits all the paths passed via pipe - except the software downloaded via nvm.
#
fn filter-out-downloads {
  all |
    keep-if (lang:negate $files:is-downloaded~)
}

#
# Returns the PATH entry for the given downloaded NodeJS version.
#
fn get-entry-for-node { |node-version|
  path:join $files:node-download-root $node-version bin
}

#
# Emits the path entry for the given NodeJS version, followed by any path entry passed via pipe **except** the ones in nvm's download directory.
#
fn ensure-node-version { |node-version|
  get-entry-for-node $node-version

  filter-out-downloads
}
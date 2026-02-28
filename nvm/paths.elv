use path
use github.com/giancosta86/ethereal/v1/lang
use ./files
use ./wrapper

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
# Sets the system PATH so as to include the `nvm current` binary - and no other nvm downloads.
#
fn ensure-current {
  var entry-for-current = (
    wrapper:nvm which current |
      path:dir (all)
  )

  var paths-without-downloads = [(
    all $paths |
      filter-out-downloads
    )]

  set paths = [
    $entry-for-current

    $@paths-without-downloads
  ]
}
use path
use ./files
use ./wrapper

#
# Emits all the paths passed via pipe - except the software downloaded by nvm.
#
fn filter-out-nvm-downloaded {
  all |
    keep-if $files:is-not-downloaded~
}

#
# Returns the PATH entry for the given NodeJS version.
#
fn get-entry-for { |node-version|
  path:join $files:download-node-root $node-version bin
}

#
# Sets the system PATH so as to include the `nvm current` binary - and no other NodeJS downloaded via nvm.
#
fn ensure-current-node {
  var current-node-bin-directory = (
    wrapper:nvm which current |
      path:dir (all)
  )

  var paths-without-nvm-downloaded = [(
    all $paths |
      filter-out-nvm-downloaded
  )]

  set paths = [
    $current-node-bin-directory

    $@paths-without-nvm-downloaded
  ]
}
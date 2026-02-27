use path
use ./files
use ./wrapper

#
# Emits all the paths passed via pipe - except the NodeJS versions downloaded by nvm.
#
fn filter-out-nvm-nodes {
  all |
    keep-if $files:is-not-downloaded-node~
}

#
# Returns the PATH entry for the given NodeJS version.
#
fn get-entry-for { |node-version|
  path:join $files:downloaded-node-root $node-version bin
}

#
# Sets the system PATH so as to include the `nvm current` binary - and no other NodeJS downloaded via nvm.
#
fn ensure-current-node {
  var current-node-bin-directory = (
    wrapper:nvm which current |
      path:dir (all)
  )

  var paths-without-nvm-nodes = [(
    all $paths |
      filter-out-nvm-nodes
  )]

  set paths = [
    $current-node-bin-directory

    $@paths-without-nvm-nodes
  ]
}
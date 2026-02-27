use path
use ./files
use ./wrapper


fn get-without-node {
  put [(
    all $paths |
      keep-if $files:is-not-downloaded-node~
  )]
}

fn ensure-current-node {
  var current-node-directory = (
    wrapper:nvm which current |
      path:dir (all)
  )

  var paths-without-node = (get-without-node)

  set paths = [
    $current-node-directory

    $@paths-without-node
  ]
}
use path
use ./wrapper
use ./files

fn get-without-nodejs {
  put [(
    all $paths |
      keep-if $files:is-not-downloaded-nodejs-bin~
  )]
}

fn ensure-current-nodejs {
  var current-node-directory = (
    wrapper:nvm which current |
      path:dir (all)
  )

  var paths-without-nodejs = (get-without-nodejs)

  set paths = [
    $current-node-directory

    $@paths-without-nodejs
  ]
}
use path
use ./bridge
use ./files

fn get-without-nodejs {
  put [(
    all $paths |
      keep-if $files:is-not-downloaded-nodejs~
  )]
}

fn -ensure-nvm-node-executable-in-paths { |node-executable|
  var paths-without-any-downloaded-nodejs = (get-without-nodejs)

  set paths = [
    (path:dir $node-executable)

    $@paths-without-any-downloaded-nodejs
  ]
}

fn ensure-current-nodejs {
  bridge:nvm which current |
    -ensure-nvm-node-executable-in-paths (all)
}
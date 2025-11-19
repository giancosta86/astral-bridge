use path
use str
use github.com/giancosta86/ethereal/command
use github.com/giancosta86/ethereal/lang
use github.com/giancosta86/ethereal/seq
use ./version

var -nvm-home = (path:join ~ .nvm)

var -boot-script = (path:join $-nvm-home nvm.sh)

var -downloaded-nodejs-versions-dir = (path:join $-nvm-home versions)

var -current-node-version = $nil

fn -is-not-downloaded-nodejs-directory { |path|
  str:has-prefix $path $-downloaded-nodejs-versions-dir''$path:separator |
    not (all)
}

fn -get-paths-without-downloaded-nodejs {
  put [(
    all $paths |
      keep-if $-is-not-downloaded-nodejs-directory~
  )]
}

fn -ensure-nvm-node-executable-in-paths { |node-executable|
  var paths-without-any-downloaded-nodejs = (-get-paths-without-downloaded-nodejs)

  set paths = [
    (path:dir $node-executable)

    $@paths-without-any-downloaded-nodejs
  ]
}

fn nvm { |@arguments|
  var restore-current-node-version-command = (
    if $-current-node-version {
      put 'nvm use '$-current-node-version
    } else {
      put $nil
    }
  )

  var command-lines = (
    all [
      'source '$-boot-script

      (all (seq:value-as-list $restore-current-node-version-command))

      'nvm '(str:join " " [$@arguments])

      'nvm current'
    ] |
      keep-if { |line| > (count $line) 0} |
      str:join '; ' |
      bash -c (all)|
      put [(all)]
  )

  all $command-lines[1..-1] | each $echo~

  set -current-node-version = $command-lines[-1]
}

fn ensure-current-node-in-path {
  nvm which current |
    -ensure-nvm-node-executable-in-paths (all)
}

fn after-chdir-hook { |path|
  var requested-node-version = (version:detect-recursively $path)

  if $requested-node-version {
    var current-node-version = (nvm current | lang:ensure-put)

    if (not-eq $current-node-version $requested-node-version) {
      nvm install $requested-node-version

      ensure-current-node-in-path
    }
  }
}
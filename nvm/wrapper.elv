use str
use ./files
use github.com/giancosta86/ethereal/v1/seq

var nvm~ = (
  var current-node-version = $nil

  put { |@arguments|
    var restore-current-node-version-command = (
      if $current-node-version {
        put 'nvm use '$current-node-version
      } else {
        put ''
      }
    )

    var command-lines = [(
      all [
        'source '$files:boot-script

        $restore-current-node-version-command

        'nvm '(str:join " " $arguments)

        'nvm current'
      ] |
        keep-if $seq:is-non-empty~ |
        str:join '; ' |
        bash -c (all)
    )]

    all $command-lines[1..-1] | each $echo~

    set current-node-version = $command-lines[-1]
  }
)
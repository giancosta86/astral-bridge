use str
use ./files
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/seq

#
# Wraps the core Bash script for nvm - forwarding all of its arguments.
#
var nvm~ = (
  var current-node-version = $nil

  put { |@arguments|
    var should-restore-current-node-version = (
      and $current-node-version (!=s $arguments[0] use)
    )

    var restore-current-node-version-command = (
      if $should-restore-current-node-version {
        put 'nvm use '$current-node-version
      } else {
        put ''
      }
    )

    var bash-output-lines = [(
      all [
        'source '$files:bash-script

        $restore-current-node-version-command

        'nvm '(str:join " " $arguments)

        'nvm current'
      ] |
        keep-if $seq:is-non-empty~ |
        str:join '; ' |
        bash -c (all)
    )]

    var lines-to-skip = (lang:ternary $should-restore-current-node-version 1 0)

    all $bash-output-lines[$lines-to-skip..-1] |
      each $echo~

    set current-node-version = $bash-output-lines[-1]
  }
)
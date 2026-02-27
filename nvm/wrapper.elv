use str
use ./files
use github.com/giancosta86/ethereal/v1/seq

#
# Wraps the core Bash script for nvm - forwarding all of its arguments.
#
var nvm~ = (
  var current-node-version = $nil

  put { |@arguments|
    var should-restore-current-node-version = (
      and $current-node-version (not-eq $arguments[0] use)
    )

    var restore-current-node-version-command = (
      if $should-restore-current-node-version {
        put 'nvm use '$current-node-version
      } else {
        put ''
      }
    )

    var command-lines = [(
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

    var output-lines = (
      if $should-restore-current-node-version {
        put $command-lines[1..-1]
      } else {
        put $command-lines[..-1]
      }
    )

    all $output-lines | each $echo~

    set current-node-version = $command-lines[-1]
  }
)
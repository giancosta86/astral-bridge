use os
use path
use ./cd-hooks
use ./wrapper

fn get-nvm-runs { |block|
  var current-node-version = $nil

  var spy = (command:spy { |@arguments|
    var command = $arguments[0]

    if (eq $command current) {
      put $current-node-version
    } elif (has-value [install use] $command) {
      set current-node-version = $arguments[-1]
    }
  })

  tmp wrapper:nvm~ = $spy[command]

  $block

  $spy[get-runs]
}

>> 'nvm' {
  >> 'cd hooks' {
    >> 'when no version is requested' {
      get-nvm-runs {
        fs:within-temp-dir {
          cd-hooks:-after-cd
        }
      } |
        should-be []
    }

    >> 'when version is requested via .nvmrc file in ancestor directory' {
      get-nvm-runs {
        wrapper:nvm use ALPHA

        fs:within-temp-dir {
          echo BETA > .nvmrc

          var nested-dir = (path:join alpha beta gamma)

          os:mkdir-all $nested-dir
          cd $nested-dir

          cd-hooks:-after-cd
        }
      } |
        should-be [
          [use ALPHA]

          [current]

          [install --no-progress BETA]
        ]
    }

    >> 'when version is requested via package.json in ancestor directory' {
      get-nvm-runs {
        wrapper:nvm use RO

        fs:within-temp-dir {
          put [
            &engines=[
              &node=v1.2.3
            ]
          ] |
            to-json > package.json

          var nested-dir = (path:join alpha beta gamma)

          os:mkdir-all $nested-dir
          cd $nested-dir

          cd-hooks:-after-cd
        }
      } |
        should-be [
          [use RO]

          [current]

          [install --no-progress v1.2.3]
        ]
    }

    >> 'registration' {
      >> 'should run the hook on the current directory' {
        get-nvm-runs {
          wrapper:nvm use OMICRON

          fs:within-temp-dir {
            put [
              &engines=[
                &node=v90.92.98
              ]
            ] |
              to-json > package.json

            var nested-dir = (path:join alpha beta gamma)

            fs:mkcd $nested-dir

            cd-hooks:register
          }
        } |
          should-be [
            [use OMICRON]

            [--version]

            [current]

            [install --no-progress v90.92.98]
          ]
      }
    }
  }
}
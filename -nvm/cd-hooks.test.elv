use os
use path
use ./cd-hooks
use ./paths
use ./wrapper

fn get-nvm-runs { |block|
  var spy = (command:spy)

  tmp wrapper:nvm~ = $spy[command]

  $block

  $spy[get-runs]
}

fn get-nvm-bin-for { |version|
  path:join $paths:nvm-home versions node $version bin
}

>> 'nvm' {
  >> 'detecting current version' {
    >> 'when detectable' {
      tmp E:NVM_BIN = (get-nvm-bin-for v25.4.0)

      cd-hooks:-detect-current-node |
        should-be v25.4.0
    }

    >> 'when not detectable' {
      tmp E:NVM_BIN = ''

      cd-hooks:-detect-current-node |
        should-be $nil
    }
  }

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
        tmp E:NVM_BIN = (get-nvm-bin-for ALPHA)

        fs:within-temp-dir {
          echo BETA > .nvmrc

          var nested-dir = (path:join alpha beta gamma)

          fs:mkcd $nested-dir

          cd-hooks:-after-cd
        }
      } |
        should-be [
          [install --no-progress vBETA]
        ]
    }

    >> 'when version is requested via package.json in ancestor directory' {
      get-nvm-runs {
        tmp E:NVM_BIN = (get-nvm-bin-for RO)

        fs:within-temp-dir {
          put [
            &engines=[
              &node=1.2.3
            ]
          ] |
            to-json > package.json

          var nested-dir = (path:join alpha beta gamma)

          fs:mkcd $nested-dir

          cd-hooks:-after-cd
        }
      } |
        should-be [
          [install --no-progress v1.2.3]
        ]
    }

    >> 'when the requested version coincides with the current one' {
      get-nvm-runs {
        tmp E:NVM_BIN = (get-nvm-bin-for v26.7.0)

        fs:within-temp-dir {
          put [
            &engines=[
              &node=26.7.0
            ]
          ] |
            to-json > package.json

          var nested-dir = (path:join alpha beta gamma)

          fs:mkcd $nested-dir

          cd-hooks:-after-cd
        }
      } |
        should-be []
    }

    >> 'registration' {
      >> 'should run the hook on the current directory' {
        get-nvm-runs {
          tmp E:NVM_BIN = (get-nvm-bin-for OMICRON)

          fs:within-temp-dir {
            put [
              &engines=[
                &node=90.92.98
              ]
            ] |
              to-json > package.json

            var nested-dir = (path:join alpha beta gamma)

            fs:mkcd $nested-dir

            cd-hooks:register
          }
        } |
          should-be [
            [--version]

            [install --no-progress v90.92.98]
          ]
      }
    }
  }
}
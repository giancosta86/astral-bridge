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

  >> 'testing for version equality' {
    >> 'when the versions are exactly the same' {
      var version = 26.7.0

      cd-hooks:-are-node-versions-equal $version $version |
        should-be $true
    }

    >> 'when the versions only differ by a v' {
      var version = 5.4.3

      cd-hooks:-are-node-versions-equal 'v'$version $version |
        should-be $true
    }

    >> 'when the versions are different' {
      cd-hooks:-are-node-versions-equal 12.3.4 9.8.7 |
        should-be $false
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
        tmp E:NVM_BIN = (get-nvm-bin-for SOME-VER)

        fs:within-temp-dir {
          echo 17.1.0 > .nvmrc

          var nested-dir = (path:join alpha beta gamma)

          fs:mkcd $nested-dir

          cd-hooks:-after-cd
        }
      } |
        should-be [
          [install --no-progress 17.1.0]
        ]
    }

    >> 'when version is requested via package.json in ancestor directory' {
      get-nvm-runs {
        tmp E:NVM_BIN = (get-nvm-bin-for SOME-VER)

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
          [install --no-progress 1.2.3]
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
          tmp E:NVM_BIN = (get-nvm-bin-for SOME-VER)

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

            [install --no-progress 90.92.98]
          ]
      }
    }
  }
}
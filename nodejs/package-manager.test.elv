use ./package-manager

>> 'NodeJS' {
  >> 'package manager' {
    >> 'detection' {
      >> 'from package.json' {
        fn expect-package-manager { |package-json expected-package-manager|
          fs:within-temp-dir {
            if $package-json {
              put $package-json |
                to-json > package.json
            }

            package-manager:detect-from-package-json |
              should-be $expected-package-manager
          }
        }

        >> 'when package.json is missing' {
          expect-package-manager $nil $nil
        }

        >> 'when package.json has no supported fields' {
          expect-package-manager [&] $nil
        }

        >> 'when the root packageManager field is declared' {
          >> 'with name and version' {
            expect-package-manager [
              &packageManager=yarn@3.2.3
            ] yarn
          }

          >> 'with just the name' {
            expect-package-manager [
              &packageManager=pnpm
            ] pnpm
          }
        }

        >> 'when the devEngines/packageManager field is declared' {
          expect-package-manager [
            &devEngines=[
              &packageManager=[
                &name=yarn
                &version=3.2.3
              ]
            ]
          ] yarn
        }

        >> 'when both fields are declared' {
          expect-package-manager [
            &packageManager=pnpm
            &devEngines=[
              &packageManager=[
                &name=yarn
                &version=3.2.3
              ]
            ]
          ] pnpm
        }
      }

      >> 'from lockfile' {
        >> 'when no lockfile is present' {
          fs:within-temp-dir {
            package-manager:detect-from-lockfile |
              should-be $nil
          }
        }

        >> 'when pnpm lockfile is present' {
          fs:within-temp-dir {
            fs:touch pnpm-lock.yaml

            package-manager:detect-from-lockfile |
              should-be pnpm
          }
        }

        >> 'when yarn lockfile is present' {
          fs:within-temp-dir {
            fs:touch yarn.lock

            package-manager:detect-from-lockfile |
              should-be yarn
          }
        }

        >> 'when npm lockfile is present' {
          fs:within-temp-dir {
            fs:touch package-lock.json

            package-manager:detect-from-lockfile |
              should-be npm
          }
        }
      }

      >> 'with multiple methods' {
        >> 'when package.json is conclusive' {
          fs:within-temp-dir {
            put [
              &packageManager=yarn@3.2.3
            ] |
              to-json > package.json

            package-manager:detect |
              should-be yarn
          }
        }

        >> 'when lockfile is conclusive' {
          fs:within-temp-dir {
            fs:touch pnpm-lock.yaml

            package-manager:detect |
              should-be pnpm
          }
        }

        >> 'when no clue is available' {
          fs:within-temp-dir {
            package-manager:detect |
              should-be npm
          }
        }
      }
    }

    >> 'execution' {
      fn expect-package-manager { |&install=$true expected-package-manager block-within-temp-dir|
        var resolver-spy = (command:spy { |package-manager-command|
          put { |@package-manager-arguments|
            put SAMPLE-VERSION
          }
        })

        tmp package-manager:-resolve-command~ = $resolver-spy[command]

        fs:within-temp-dir {
          $block-within-temp-dir

          package-manager:exec &install=$install --version |
            should-be SAMPLE-VERSION

          $resolver-spy[get-runs] |
            should-be [
              [$expected-package-manager]
            ]
        }
      }

      fn write-package-json-with-pnpm {
        put [
          &packageManager=pnpm@10.22.0
        ] |
          to-json > package.json
      }

      >> 'when corepack is not installed' {
        tmp package-manager:-is-corepack-installed~ = { put $false }

        tmp package-manager:-corepack~ = { |_| fail 'This should never be invoked' }

        >> 'when the package manager is declared in package.json' {
          expect-package-manager pnpm {
            write-package-json-with-pnpm
          }
        }
      }

      >> 'when corepack is installed' {
        tmp package-manager:-is-corepack-installed~ = { put $true }

        >> 'when no clue is available' {
          tmp package-manager:-corepack~ = { |_| fail 'This should never be called!' }

          expect-package-manager npm { }
        }

        >> 'when only the lockfile is available' {
          tmp package-manager:-corepack~ = { |_| fail 'This should never be called!' }

          expect-package-manager yarn {
            fs:touch yarn.lock
          }
        }

        >> 'when the package manager is declared in package.json' {
          var corepack-spy = (command:spy)

          tmp package-manager:-corepack~ = $corepack-spy[command]

          expect-package-manager pnpm {
            write-package-json-with-pnpm
          }

          $corepack-spy[get-runs] |
            should-be [
              [install]
            ]
        }

        >> 'when the install flag is disabled' {
          tmp package-manager:-corepack~ = { |_| fail 'This should never be called!' }

          expect-package-manager &install=$false pnpm {
            write-package-json-with-pnpm
          }
        }
      }
    }

    >> 'scripts' {
      >> 'detection' {
        >> 'when package.json is missing' {
          fs:within-temp-dir {
            package-manager:has-script my-script |
              should-be $false
          }
        }

        >> 'when package.json is empty' {
          fs:within-temp-dir {
            put [&] |
              to-json > package.json

            package-manager:has-script my-script |
              should-be $false
          }
        }

        >> 'when package.json has other scripts' {
          fs:within-temp-dir {
            put [
              &scripts=[
                [&other-script='...']
              ]
            ] |
              to-json > package.json

            package-manager:has-script my-script |
              should-be $false
          }
        }

        >> 'when package.json has the requested script' {
          fs:within-temp-dir {
            put [
              &scripts=[
                &my-script='...'
              ]
            ] |
              to-json > package.json

            package-manager:has-script my-script |
              should-be $true
          }
        }
      }

      >> 'execution' {
        >> 'when package.json is missing' {
          >> 'by default' {
            fs:within-temp-dir {
              fails {
                package-manager:run-script my-script
              } |
                should-be 'Missing script in package.json: my-script'
            }
          }

          >> 'when optional' {
            fs:within-temp-dir {
              package-manager:run-script &optional my-script
            }
          }
        }

        >> 'when package.json has the requested script' {
          fs:within-temp-dir {
            put [
              &scripts=[
                &my-script='echo Greetings!'
              ]
            ] |
              to-json > package.json

            capture {
              put my-script |
                package-manager:run-script
            } |
              should-contain 'Greetings!'
          }
        }
      }
    }

    #         package-manager:run-script &optional=$optional start

    #         slurp < test.txt |
    #           should-be "Hello\n"
    #       }
    #     }
    #   }

    #   >> 'when required' {
    #     run-suite
    #   }

    #   >> 'when optional' {
    #     run-suite &optional
    #   }
    # }
  }
}
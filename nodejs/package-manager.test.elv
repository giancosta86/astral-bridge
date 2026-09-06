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

    # >> 'running' {
    #   >> 'when the package manager is declared in package.json' {
    #     all [
    #       [yarn 3.2.3]
    #       [pnpm 11.4.0]
    #     ] | seq:spread { |name version|
    #       >> 'for '$name {
    #         fs:within-temp-dir {
    #           put [
    #             &packageManager=$name'@'$version
    #           ] |
    #             to-json > package.json

    #           package-manager:exec --version |
    #             should-match-regex '\b'$version'\b'
    #         }
    #       }
    #     }
    #   }

    #   >> 'when package.json is missing' {
    #     fs:within-temp-dir {
    #       package-manager:exec --version |
    #         should-be $shared:main-npm-version
    #     }
    #   }

    #   >> 'when package.json and npm lockfile are present' {
    #     fs:within-temp-dir {
    #       put [&] | to-json > package.json

    #       fs:touch package-lock.json

    #       package-manager:exec --version |
    #         should-be $shared:main-npm-version
    #     }
    #   }
    # }

    # >> 'running package script' {
    #   fn run-suite { |&optional=$false|
    #     var assertion-message-extractor = (
    #       if $optional {
    #         put $capture~
    #       } else {
    #         put $fails~
    #       }
    #     )

    #     >> 'when package.json does not exist' {
    #       fs:within-temp-dir {
    #         $assertion-message-extractor {
    #           package-manager:run-script &optional=$optional start
    #         } |
    #           should-be '💭 Cannot find package.json - will not run the ''start'' script...'
    #       }
    #     }

    #     >> 'when package.json has no scripts section' {
    #       fs:within-temp-dir {
    #         put [&] |
    #           to-json > package.json

    #         $assertion-message-extractor {
    #           package-manager:run-script &optional=$optional start
    #         } |
    #           should-be '💭 Cannot find the ''start'' script in package.json...'
    #       }
    #     }

    #     >> 'when package.json has scripts, but not the requested one' {
    #       fs:within-temp-dir {
    #         put [
    #           &scripts=[
    #             &dodo='echo Hello'
    #           ]
    #         ] |
    #           to-json > package.json

    #         $assertion-message-extractor {
    #           package-manager:run-script &optional=$optional start
    #         } |
    #           should-be '💭 Cannot find the ''start'' script in package.json...'
    #       }
    #     }

    #     >> 'when package.json has the requested script' {
    #       fs:within-temp-dir {
    #         put [
    #           &scripts=[
    #             &start='echo Hello > test.txt'
    #           ]
    #         ] |
    #           to-json > package.json

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
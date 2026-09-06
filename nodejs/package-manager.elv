use os
use str
use github.com/giancosta86/ethereal/v1/command
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/seq

#
# Emits the name of the package manager described in package.json,
# in any of the fields supported by corepack:
#
# 1. packageManager
#
# 2. devEngines/packageManager
#
# If package.json is missing or such fields can't be found,
# emits $nil instead.
#
fn detect-from-package-json {
  if (not (os:is-regular package.json)) {
    put $nil
    return
  }

  var package-json = (
    from-json < package.json
  )

  seq:drill-down $package-json packageManager |
    lang:map { |root-package-manager|
      str:split @ $root-package-manager |
        take 1
    } |
    lang:otherwise {
      seq:drill-down $package-json devEngines packageManager name
    }
}

#
# Emits the package manager inferred from the existing lockfile - or $nil if no supported lockfile was found.
#
var detect-from-lockfile~ = (
  var package-managers-by-lockfile = [
    &'pnpm-lock.yaml'=pnpm
    &'yarn.lock'=yarn
    &'package-lock.json'=npm
  ]

  put {
    keys $package-managers-by-lockfile | each { |lockfile|
      if (os:is-regular $lockfile) {
        put $package-managers-by-lockfile[$lockfile]
        return
      }
    }

    put $nil
  }
)

#
# Detects the package manager requested in the current directory, returning the command itself, or "npm" if none could be detected.
#
# The detection algorithm works as follows:
#
# 1. Run `detect-from-package-json` - emitting a non-$nil result
#
# 2. Run `detect-from-lockfile` - emitting a non-$nil result
#
# 3. Finally, if nothing else worked, the default "npm" is returned.
#
fn detect {
  detect-from-package-json |
    lang:otherwise $detect-from-lockfile~ |
    coalesce (all) npm
}

#
# Runs the given command using the best version for the requested package manager in the current directory:
#
# 1. Use the `detect` function to detect the package manager for the project.
#
# 2. If `&ensure-installed` is enabled:
#
#    1. Verify these conditions are all met:
#
#       * the detected package manager is `npm`
#
#       * `corepack` is available as a command
#
#       * the package manager in package.json, within the current directory, is the detected one
#
#       If any of the above conditions is not met, don't proceed to the following steps.
#
#    2. Execute `corepack install`, to ensure the requested package manager version is available
#
#    3. Run the requested package manager, forwarding all the arguments.
#
fn exec { |&ensure-installed=$true @arguments|
  var detected-package-manager = (detect)

  var not-using-npm = (
    not-eq $detected-package-manager npm
  )

  if $detected-package-manager {
    if (and $ensure-installed (has-external corepack) $not-using-npm) {
      var detected-from-package-json = (-detect-from-package-json)

      if (eq $detected-from-package-json $detected-package-manager) {
        command:silence {
          corepack install
        }
      }
    }

    (external $detected-package-manager) $@arguments
  } else {
    npm $@arguments
  }
}

#
# If package.json exists and contains the required script in its "scripts" section, runs it.
#
fn run-script { |script &optional=$false|
  var notify-error~ = { |message|
    if $optional {
      echo $message
      return
    } else {
      fail $message
    }
  }

  if (not (os:is-regular package.json)) {
    notify-error '💭 Cannot find package.json - will not run the '''$script''' script...'
  }

  var package-json = (from-json < package.json)

  if (seq:drill-down $package-json scripts $script) {
    echo 💫 Now running the "'"$script"'" script from package.json...

    exec run $script

    echo ✅ "'"$script"'" script executed!
  } else {
    notify-error '💭 Cannot find the '''$script''' script in package.json...'
  }
}
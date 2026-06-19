use os
use str
use github.com/giancosta86/ethereal/v1/command
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/seq

fn -parse-from-package-json { |@arguments|
  var package-json = (lang:get-single-input $arguments)

  seq:drill-down $package-json packageManager |
    lang:map { |root-package-manager|
      str:split @ $root-package-manager |
        take 1
    } |
    lang:otherwise {
      seq:drill-down $package-json devEngines packageManager name
    }
}

var -detect-from-lockfile~ = (
  var package-managers-by-lockfile = [
    &'package-lock.json'=npm
    &'yarn.lock'=yarn
    &'pnpm-lock.yaml'=pnpm
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
# Detects the package manager requested in the current directory, returning the command itself, or $nil if none could be detected.
#
# The detection algorithm works as follows:
#
# 1. If package.json exists and one of the supported fields (`packageManager` or `devEngines/packageManager/name`) is declared, return the package name.
#
# 2. Otherwise, check the existence of one of the main lockfiles - returning the corresponding package manager command.
#
# 3. Finally, if nothing else worked, $nil is returned.
#
fn detect {
  if (os:is-regular package.json) {
    from-json < package.json |
      -parse-from-package-json
  } else {
    put $nil
  } |
    lang:otherwise {
      -detect-from-lockfile
    }
}

#
# Runs the given command using the best version for the requested package manager in the current directory:
#
# 1. If `&ensure-installed` is enabled, `corepack` is available as a command and package.json exists, execute `corepack install`, to ensure the requested package manager version is available.
#
# 2. Use the `detect` function to detect the command of the package manager, defaulting to `npm`
#
# 3. Run the package manager, forwarding all the arguments.
#
fn exec { |&ensure-installed=$true @arguments|
  if (and $ensure-installed (has-external corepack) (os:is-regular package.json)) {
    command:silence {
      corepack install
    }
  }

  var command = (
    detect |
      coalesce (all) npm
  )

  (external $command) $@arguments
}
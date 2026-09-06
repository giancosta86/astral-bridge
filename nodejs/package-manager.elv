use os
use str
use github.com/giancosta86/ethereal/v1/command
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/seq

var -corepack~ = (external corepack)

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

fn -is-corepack-installed {
  has-external corepack
}

fn -resolve-command { |command|
  external $command
}

#
# Runs the given command via the best version for the requested package manager in the current directory:
#
# 1. Call the `detect` function to infer the package manager for the project.
#
# 2. If these conditions are all met:
#
#    * `&ensure-installed` is enabled
#
#    * the detected package manager is NOT `npm`
#
#    * `corepack` is available as a command
#
#    * the package manager declared in package.json matches the one already detected
#
#    then execute `corepack install`, to ensure the requested package manager is installed.
#
# 3. Run the requested package manager, forwarding all the arguments.
#
fn exec { |&install=$true @arguments|
  var detected-package-manager = (detect)

  var not-using-npm = (
    not-eq $detected-package-manager npm
  )

  if (and $install $not-using-npm (-is-corepack-installed)) {
    var detected-from-package-json = (detect-from-package-json)

    if (eq $detected-package-manager $detected-from-package-json) {
      command:silence {
        -corepack install
      }
    }
  }

  (-resolve-command $detected-package-manager) $@arguments
}

#
# Emits whether package.json exists and contains the required script in its "scripts" section.
#
fn has-script { |@arguments|
  var script = (lang:get-single-input $arguments)

  if (not (os:is-regular package.json)) {
    put $false
    return
  }

  var package-json = (from-json < package.json)

  seq:drill-down $package-json scripts $script |
    not-eq $nil (all)
}

#
# If package.json exists and contains the required script in its "scripts" section,
# runs it, unless the &optional flag is set.
#
fn run-script { |&optional=$false @arguments|
  var script = (lang:get-single-input $arguments)

  if (has-script $script) {
    exec run $script
  } else {
    if (not $optional) {
      fail 'Missing script in package.json: '$script
    }
  }
}
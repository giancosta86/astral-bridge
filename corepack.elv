use github.com/giancosta86/ethereal/v1/command

#
# Ensures that corepack is installed and enabled.
#
fn setup { |&support-npm=$false|
  if (has-external corepack) {
    echo 🌟 corepack already installed!
  } else {
    echo 📥 Installing corepack...

    command:silence {
      npm install --global corepack
    }

    echo 💽 corepack installed!
  }

  echo 🔗 Enabling corepack...

  command:silence {
    corepack enable
  }

  echo 🟢 corepack enabled!

  if $support-npm {
    deprecate 'Support for npm was unstable; it has currently no effect and will be removed from the next major version'
  }

  echo 🚀 corepack ready!
}
use github.com/giancosta86/ethereal/v1/command

#
# Ensures that corepack is installed and enabled - also supporting npm aliasing.
#
fn setup { |&support-npm=$true|
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
    echo 📦 Enabling support for npm, too...

    command:silence {
      corepack enable npm
    }

    echo 🪅 npm now supported by corepack!
  }

  echo 🚀 corepack ready!
}
use path
use ./files

>> 'nvm' {
  >> 'files' {
    >> 'testing for downloaded NodeJS path' {
      >> 'when it is actually a NodeJS path' {
        path:join $files:downloaded-nodejs-root node v20.15.1 |
          files:is-not-downloaded-nodejs
      }

      >> 'when it is not a NodeJS path' {
        files:is-not-downloaded-nodejs /
      }
    }
  }
}
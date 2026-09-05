use ./wrapper

>> 'nvm' {
  >> 'wrapper command' {
    >> 'should be invokable with no arguments' {
      wrapper:nvm --version |
        should-match-regex '\d+\.\d+\.\d+'
    }
  }
}
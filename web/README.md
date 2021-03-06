# NoKey Web

This is the shared part of the password manager.
This website can later be embedded in the browser extension, the android app, etc.

## Develop

### Setup

 * Install [elm](http://elm-lang.org/)
 * Install [elm-github-install](https://github.com/gdotdesign/elm-github-install) (for [elm-phoenix](https://github.com/saschatimme/elm-phoenix))
 * install dependencies: `elm-github-install`
 * (Optional) for a nice live reload server, install [elm-live](https://github.com/tomekwi/elm-live)
 * (Optional) to run tests, install [elm-test](https://github.com/elm-community/elm-test/tree/master) and [elm-verify-examples](https://github.com/stoeffel/elm-verify-examples)

### Run

To compile, run `elm make src/Main.elm --output=build/main.js`

For live reload + debugger, run `elm live src/Main.elm --output=build/main.js --debug`

To run tests, run `elm-verify-examples && elm-test`


## Release

 * Bump version in Data/Settings
 * Write release log in Views/ReleaseLog


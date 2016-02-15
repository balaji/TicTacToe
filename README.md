# TicTacToe [![Travis CI Build status](https://travis-ci.org/balaji/TicTacToe.svg?branch=master "Travis CI")](https://travis-ci.org/balaji/TicTacToe)

Browser based game of Tic-Tac-Toe.

### Prerequisites
* ruby (`v2.3.0`)
* Bundler (Install command: `gem install bundler`)
* npm
* Browserify & Watchify (Install command: `npm install -g browserify watchify`)

### Local machine setup

```
$ bundle install
$ npm install
$ bundle exec rackup
[2016-02-14 12:31:30] INFO  WEBrick 1.3.1
[2016-02-14 12:31:30] INFO  ruby 2.3.0 (2015-12-25) [x86_64-darwin15]
[2016-02-14 12:31:30] INFO  WEBrick::HTTPServer#start: pid=48751 port=9292
...
```
open another terminal and type. The below command live reloads the updated javascript file on editing.

```
watchify -t [ babelify --presets [ react ] ] public/js/src/app.js -o public/js/static/bundle.js
```
### Static code analysis / Linting

```
$ npm install -g eslint eslint-plugin-promise eslint-plugin-standard eslint-plugin-react

# For ruby files
$ bundle exec rubocop

# for js files
$ eslint public/js/src/app.js public/js/src/localStore.js
```

### Frameworks used

* Backend: `Sinatra`
* Frontend: `React`
* Database: `sqlite3` (Heroku deployment uses `postgresql`)
* Continuous Integration: `Travis CI`
* Static code analysis/linting: `rubocop` & `eslint` 

### Demo URL
[http://balaji-tic-tac-toe.herokuapp.com/](http://balaji-tic-tac-toe.herokuapp.com/)



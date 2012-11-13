desc('Build the app!');
task('default', {async: true}, function (params) {

  var cmds = [
    'haml ./options.haml ./options.html'
  , 'coffee ./lgtm.coffee ./lgtm.js'
  ];
  jake.exec(cmds, function () {
    console.log('Build complete!');
    complete();
  }, {printStdout: true});

});

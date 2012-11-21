desc 'Build the app!'
task 'default', (params) ->

  cmds = [
    'haml ./options.haml ./options.html',
    'coffee -c ./lgtm.coffee'
  ]
  jake.exec cmds, ->
    console.log('Build complete!')
    complete()
  , {printStdout: true, printStderr: true}

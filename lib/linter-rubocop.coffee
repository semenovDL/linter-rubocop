module.exports = LinterRubocop =
  scopes: ['source.ruby', 'source.ruby.rails', 'source.ruby.rspec']

  activate: ->
    console.log 'activate rubocop'
    unless atom.packages.getLoadedPackages 'linter-plus'
      @showError '[Linter+ rubocop] `linter-plus` package not found, please install it'

  showError: (message = '') ->
    atom.notifications.addError message

  provideLinter: ->
    console.log 'xxx'
    {
      scopes: @scopes
      lint: @lint
      lintOnFly: true
    }

  lint: (TextEditor, TextBuffer, {Error}) ->
    CP = require 'child_process'
    Path = require 'path'

    return new Promise (Resolve)->
      console.log 'lint2' # I get this lint2 in my console
      FilePath = TextEditor.getPath()
      return unless FilePath # Files that have not be saved
      Data = []
      Process = CP.exec('rubocop --format json', {cwd: Path.dirname(FilePath)})
      Process.stdout.on 'data', (data)-> Data.push(data.toString())
      Process.on 'close', ->
        try
          Content = JSON.parse(Data.join(''))
        catch error then return # Ignore weird errors for now
        ToReturn = []
        return ToReturn if Content.passed
        Content.files.forEach (file)->
          console.log file
          file.offenses.forEach (offense)->
            ToReturn.push new Error offense.message, file.path, [[offense.line, offense.column],[offense.line, offense.column+offense.length]], []
        ToReturn

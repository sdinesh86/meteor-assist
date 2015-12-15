
module.exports = MeteorAssist =
  config:
    templatesFilePath:
      type:'string'
      default:"#{atom.packages.resolvePackagePath('meteor-assist')}\\templates.cson"
      title:'Templates File'
      description:'Templates File to store all the Templates data'


  activate: ( state ) ->

    # Register command for views
    atom.commands.add 'atom-workspace', 'meteor-assist:toggle-settings-view': @toggleSettingsView
    atom.commands.add '.tree-view', 'meteor-assist:toggle-template-generator': @toggleTemplatesGenerator

  toggleSettingsView: =>
    unless @maSettingsView?
      SettingsView = require './meteor-assist-settings-view'
      console.log "Creating new SettingsView"
      @maSettingsView = new SettingsView()

    @maSettingsView.toggle()

  toggleTemplatesGenerator: ->
    unless @maTemplatesGeneratorView?
      TemplatesGeneratorView = require './meteor-assist-template-selector'
      @maTemplatesGeneratorView = new TemplatesGeneratorView()

    @maTemplatesGeneratorView.toggle()

  deactivate: ->

  serialize: ->

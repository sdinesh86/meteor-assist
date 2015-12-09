MeteorAssistView = require './meteor-assist-view'
MeteorAssistSettingsView = require './meteor-assist-settings-view'
MeteorAssistUtility = require './meteor-assist-utility'

{CompositeDisposable} = require 'atom'

module.exports = MeteorAssist =
  config:
    configFilePath:
      type:'string'
      default:"#{atom.packages.resolvePackagePath('meteor-assist')}\\templatesConfig.cson"
      title:'Config file'
      description:'This file store all the data for the templates'
    precompInFolder:
      type: 'boolean'
      default: true
      title: 'Create template files is folder'
    stylesFormat:
      type: 'string'
      default: 'less'
      enum: ['less','sass','css']
    scriptFormat:
      type: 'string'
      default: 'coffeescript'
      enum: ['coffeescript', 'javascript']

  activate: (state) ->
    @meteorAssistView = new MeteorAssistView()
    @meteorAssistSettingsView = new MeteorAssistSettingsView()

    console.log "Activating the Package"

    # Register command that toggles this view
    atom.commands.add '.tree-view', 'meteor-assist:toggle': => @meteorAssistView.toggle()
    atom.commands.add 'atom-workspace', 'meteor-assist:toggle-settings-view': => @meteorAssistSettingsView.toggle()

  deactivate: ->
    @meteorAssistView.destroy()

  serialize: ->

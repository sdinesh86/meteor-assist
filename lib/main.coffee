CSON = require 'season'

TemplateSelectorDialog = null
FieldsListDialog = null

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
    atom.commands.add '.tree-view', 'meteor-assist:toggle-template-generator': ( e ) =>
      @toggleTemplatesGenerator()

  toggleSettingsView: =>
    unless @maSettingsView?
      SettingsView = require './meteor-assist-settings-view'
      console.log "Creating new SettingsView"
      @maSettingsView = new SettingsView()

    @maSettingsView.toggle()

  toggleTemplatesGenerator: ->
    configFilePath = atom.config.get('meteor-assist.templatesFilePath')
    CSON.readFile configFilePath, ( err, json ) =>
       if json?
         @showTemplatesGeneratorList( json )

  showTemplatesGeneratorList: ( json ) ->
    pkgTreeView = atom.packages.getActivePackage('tree-view')
    selectedEntry = pkgTreeView.mainModule.treeView.selectedEntry() ? pkgTreeView.mainModule.treeView.roots[0]
    selectedPath = selectedEntry?.getPath() ? ''

    TemplateSelectorDialog ?= require './meteor-assist-template-selector'
    dialog = new TemplateSelectorDialog( )
    dialog.setItems( json )
    dialog.on 'template-selected', (e, template) =>
      @toggleFieldsList( template, selectedPath )
    dialog.attach()

  toggleFieldsList: ( template, selectedPath ) ->
    FieldsListDialog ?= require './meteor-assist-fields-list'
    dialog = new FieldsListDialog( {template, selectedPath} )
    dialog.on 'confirm', ( e ) =>

    dialog.attach()

  deactivate: ->

  serialize: ->

MeteorAssistTemplateEditorPanel = require './meteor-assist-template-editor-panel'

module.exports = MeteorAssist =
  config:
    configFilePath:
      type:'string'
      default:"#{atom.packages.resolvePackagePath('meteor-assist')}\\templatesConfigPath.cson"
      title:'Config file'
      description:'This file store all the data for the templates'

  activate: (state) ->
    @meteorAssistTemplateEditorPanel = new MeteorAssistTemplateEditorPanel()

    # Register command that toggles this view
    # atom.commands.add '.tree-view', 'meteor-assist:toggle': =>
    atom.commands.add 'atom-workspace', 'meteor-assist:toggle-settings-view': =>
      # unless @meteorAssistTemplateEditorPanel?
      @meteorAssistTemplateEditorPanel.toggle()

  deactivate: ->


  serialize: ->

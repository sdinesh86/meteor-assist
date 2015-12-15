{View, $} = require 'atom-space-pen-views'
TemplatesTreeView = require './meteor-assist-templates-tree-view'
CSON = require 'season'
Path = require 'path'

module.exports =
class MeteorAssistSettingsView extends View
  settingsObject: {}

  @content: ->
    @div class:'ma-settings-view-wrapper', =>
      @div class:'ma-panel-header', =>
        @span class:'icon icon-package text-error'
        @span 'Meteor Assist Settings View',class:'text-highlight'
        @div class:'pull-right', =>
          @button 'Save', class:'padded btn btn-success icon icon-file-code', click:'saveSettings'
      @div class:'ma-panel-body', =>
        @div class:'ma-left-pane', =>
          @subview 'h_templatesTreeView', new TemplatesTreeView()
        @div class:'ma-right-pane', =>
          @tag 'atom-text-editor', outlet:'templateContentEditor'

  constructor: ->
    super

  initialize: ->
    @h_templatesTreeView.onSelectionChanged @onTemplatesTreeViewSelectionChanged

    ceditor = @templateContentEditor[0].getModel()
    ceditor.onDidStopChanging (  ) =>
      data = @templateContentEditor.data('list-item-data')
      if data?
        data.templateContent = ceditor.getText()

    @templateContentEditor.hide()

  onTemplatesTreeViewSelectionChanged: ( view ) =>
    @templateContentEditor.fadeOut(200)
    @templateContentEditor.data('list-item-data', undefined)
    @templateContentEditor[0].getModel().setText("")
    viewData = view.data('list-item-data')

    if view? and view.length > 0
      if viewData.type =="FILE"
        @templateContentEditor.data('list-item-data', viewData)
        grammar = @getGrammarFromExtension(viewData.extension.replace('.',""))
        if grammar != undefined
          @templateContentEditor[0].getModel().setGrammar(grammar)

        if viewData.templateContent != undefined
          @templateContentEditor[0].getModel().setText(viewData.templateContent)

        @templateContentEditor.fadeIn(200)

  getGrammarFromExtension: ( ext ) ->
    grammars = atom.grammars.getGrammars()
    g = undefined
    for grammar in grammars
      if ext in grammar.fileTypes
        return g = grammar
    g

  saveSettings: ->
    configFilePath = atom.config.get('meteor-assist.templatesFilePath')
    CSON.writeFile configFilePath, @h_templatesTreeView.serializeList(), ( err, res ) ->

  hide: ->
    @panel.hide()

  show: ->
    @panel ?= atom.workspace.addBottomPanel(item:this)

    configFilePath = atom.config.get('meteor-assist.templatesFilePath')
    CSON.readFile configFilePath, ( err, json ) =>
       if json?
         @h_templatesTreeView.deSerializeList( json )

    @templateContentEditor.hide()
    @panel.show()

  toggle: ->
    if @panel?.isVisible()
      @hide()
    else
      @show()

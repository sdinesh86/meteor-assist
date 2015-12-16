{View, $, $$} = require 'atom-space-pen-views'
MeteorAssistSelectListView = require './meteor-assist-select-view'
MeteorAssistUtilities = require './meteor-assist-utilities'

module.exports =
class MeteorAssistBottomPanel extends View

  @content: ->
    @div class:'ma-settings-view-wrapper', =>
      @div class:'ma-panel-header', =>
        @span class:'icon icon-package text-error'
        @span 'Meteor Assist Settings View',class:'text-highlight'
        @div class:'pull-right', =>
          @button 'Save', class:'padded btn btn-success icon icon-file-code', click:'saveSettings'
      @div class:'ma-panel-body', =>
        @div class:'ma-left-pane', =>
          @subview 'maSelectListView', new MeteorAssistSelectListView()
        @div class:'ma-right-pane', outlet:'maRightPane', =>
          @tag 'atom-text-editor', outlet:'templateContentEditor'

  initialize: ->
    @maSelectListView.on 'selection-changed', ( e, view ) =>
      @onSelectViewSelectionChanged( $(view) )

    ceditor = @templateContentEditor[0].getModel()
    ceditor.onDidStopChanging (  ) =>
      data = @templateContentEditor.data('list-item-data')
      if data?
        data.templateContent = ceditor.getText()

    @templateContentEditor.hide()

  # saveSettins: Save the Current state of the panel
  #
  # Returns the [Description] as `undefined`.
  saveSettings: ->
    serializedData = @maSelectListView.serializeList()
    MeteorAssistUtilities.writeTemplatesDataToFile( serializedData )

  # getGrammarFromExtension: Get the grammmar for the current file extension
  #
  # * `ext ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  getGrammarFromExtension: ( ext ) ->
    grammars = atom.grammars.getGrammars()
    g = undefined
    for grammar in grammars
      if ext in grammar.fileTypes
        return g = grammar
    g

  # onSelectViewSelectionChanged: Handler for the SelectListView selection changed
  #
  # * `view ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  onSelectViewSelectionChanged: ( view ) ->
    @templateContentEditor.hide()
    @templateContentEditor.data('list-item-data', undefined)
    @templateContentEditor[0].getModel().setText("")
    viewData = view.data('list-item-data')

    if view? and view.length > 0
      if viewData.type =="FILE"
        @templateContentEditor.data('list-item-data', viewData)
        console.log viewData
        grammar = @getGrammarFromExtension(viewData.extension.replace('.',""))
        if grammar != undefined
          @templateContentEditor[0].getModel().setGrammar(grammar)

        if viewData.templateContent != undefined
          @templateContentEditor[0].getModel().setText(viewData.templateContent)

        @templateContentEditor.fadeIn(200)

  # hide: Hide the bottom panel
  #
  # Returns the [Description] as `undefined`.
  hide: ->
    @panel.hide()

  # show: Show the Bottom Panel
  #
  # Returns the [Description] as `undefined`.
  show: ->
    @panel ?= atom.workspace.addBottomPanel(item:this)
    data = MeteorAssistUtilities.getTemplatesDataFromFile()
    @maSelectListView.populateItems(data)
    @panel.show()

  # toggle: Toggle the bottom Panel
  #
  # Returns the [Description] as `undefined`.
  toggle: ->
    if @panel?.isVisible()
      @hide()
    else
      @show()

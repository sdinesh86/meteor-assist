{View, $ } = require 'atom-space-pen-views'
TemplatesListView = require './templates-list-view'
cson = require 'season'


module.exports =
class MeteorAssistSettingsView extends View

  @content: ->
    @div class:'ma-settings-view', =>
      @div class:'ma-panel-header-menu panel-heading', =>
        @span 'Meteor Assist Settings', class:'icon icon-package'
      @div class:'ma-panel-body-wrapper panel-body', =>
        @div class:'ma-left-pane', =>
          @div class:'btn-group btn-group-sm padded', =>
            @button 'Add Group', class:'btn icon icon-database', click:'addGroupNode'
            @button 'Add Folder', class:'btn icon icon-file-directory', click:'addFolderNode'
            @button 'Add File', class:'btn icon icon-file-code', click:'addFileNode'
          @subview 'ntemplatesListView', new TemplatesListView
        @div class:'ma-right-pane', outlet:'rightPane', =>
          # @div class:'padded', =>
          #   @button 'Save ..', class:'btn btn-primary icon icon-file-code'
          @div class:'block', =>
            @tag 'atom-text-editor', class:'template-editor', outlet:'templateEditor', style:'display: none;'

  initialize: ->
    @ntemplatesListView.onSelectionChanged @selectionChanged
    @ntemplatesListView.onFileNameChanged @fileNameChanged

    @templateEditor[0].getModel().onDidStopChanging (  ) ->
      console.log "Stopped changing"

    @templateEditor.on 'keydown', ( e ) =>
      if e.ctrlKey and e.which == 83
        @saveTemplate e

  show: ->
    @panel ?= atom.workspace.addBottomPanel(item:this)
    @populateItems()
    @panel.show()

  addGroupNode: ->
    @ntemplatesListView.addItem({displayName:"Group Node", type:'GROUP'})

  addFolderNode: ->
    @ntemplatesListView.addItem({displayName:"Folder Node", type:'FOLDER'})

  addFileNode: ->
    @ntemplatesListView.addItem({displayName:"File Node", type:'FILE'})

  fileNameChanged: ( view ) =>
    @setGrammar view

  setGrammar: ( view ) ->
    data = view.data('select-list-item')
    g = atom.grammars.grammarForScopeName("source#{data.extension}")
    t = @templateEditor[0].getModel().setGrammar(g)

  selectionChanged: ( view ) =>
    if view? and view.length and view.data('select-list-item').type == 'FILE'
      @templateEditor.fadeIn(400)
      val = @ntemplatesListView.getSelectedItem().templateContent
      if val?
        @templateEditor[0].model.setText(val)
      else
        @templateEditor[0].model.setText("")
      @setGrammar view
    else
      @templateEditor.fadeOut(400)

  populateItems: ->
    configFilePath = atom.config.get 'meteor-assist.configFilePath'
    configObject = cson.readFile configFilePath, ( err, obj ) =>
      if obj?
        @ntemplatesListView.populateItems( obj )

  saveTemplate: ( e ) =>
    @ntemplatesListView.getSelectedItem().templateContent = $(e.target)[0].model.getText()
    @saveToConfig()

  saveToConfig: ->
    configObject = []
    processLi = (node) ->
      data = JSON.parse(JSON.stringify($(node).data('select-list-item')))
      $(node).find('> ol.list-group > li').each ( ) ->
        if not data.hasOwnProperty('items')
          data.items = []
        data.items.push processLi($(@))
      # Return data
      data

    @ntemplatesListView.list.children('li').each () ->
      configObject.push processLi($(@))

    configFilePath = atom.config.get('meteor-assist.configFilePath')
    cson.writeFile configFilePath, configObject

  toggle: ->
    if @panel?.isVisible()
      @panel.hide()
    else
      @show()

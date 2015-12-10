{View, $} = require 'atom-space-pen-views'
TemplatesTreeView = require './meteor-assist-templates-tree-view'
CSON = require 'season'

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

    @templateContentEditor.hide()

  onTemplatesTreeViewSelectionChanged: ( view ) =>
    @templateContentEditor.fadeOut(500)
    if view? and view.length > 0
      if view.data('list-item-data').type =="FILE"
        @templateContentEditor.fadeIn(500)

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
    @panel.show()

  toggle: ->
    if @panel?.isVisible()
      @hide()
    else
      @show()

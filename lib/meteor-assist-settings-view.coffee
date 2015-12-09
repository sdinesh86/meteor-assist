{View, $} = require 'atom-space-pen-views'
TemplatesTreeView = require './meteor-assist-templates-tree-view'
CSON = require 'season'

module.exports =
class MeteorAssistSettingsView extends View
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
        @div class:'ma-right-pane'

  constructor: ->
    super

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

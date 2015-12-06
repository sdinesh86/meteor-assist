{View, $ } = require 'atom-space-pen-views'
TemplatesListView = require './templates-list-view'

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
        @div class:'ma-right-pane', =>
          @tag 'atom-text-editor', class:'template-editor', outlet:'templateEditor', style:'display: none;'

  initialize: ->
    @ntemplatesListView.onItemSelected @templateSelected
    @templateEditor.on 'keydown', ( e ) ->
      console.log e

  show: ->
    @panel ?= atom.workspace.addBottomPanel(item:this)
    @panel.show()

  addGroupNode: ->
    @ntemplatesListView.addItem({name:'groupNode', displayName:"Group Node", type:'GROUP'})

  addFolderNode: ->
    @ntemplatesListView.addItem({name:'folderNode', displayName:"Folder Node", type:'FOLDER'})

  addFileNode: ->
    @ntemplatesListView.addItem({name:'fileNode', displayName:"File Node", type:'FILE'})

  templateSelected: ( view ) =>
    if view? and view.data('select-list-item').type == 'FILE'
      @templateEditor.fadeIn(400)
      @templateEditor[0].model.setText("")
    else
      @templateEditor.fadeOut(400)

  toggle: ->
    if @panel?.isVisible()
      @panel.hide()
    else
      @show()

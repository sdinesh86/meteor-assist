{View, SelectListView, $$, $ } = require 'atom-space-pen-views'
{Emitter} = require 'atom'
_ = require 'underscore'
CSON = require 'season'

module.exports =
class FieldsListView extends View

  @content: ->
    @div =>
      @div class:'panel-heading', =>
        @span 'List of Fields you would like to replace in the files'
      @div class:'panel-body', =>
        @div class:'fields-list select-list', =>
          @ol class:'fields-group list-group', outlet:'fieldsList'
        @div class:'btn-toolbar', =>
          @div class:'btn-group', =>
            @button 'Create', class:'btn btn-success', click:'createTemplatedFiles'
            @button 'Cancel', class:'btn btn-error', click:'close'

  initialize: ( {template, selectedPath}={} ) ->
    @addClass('templates-fields-list')

    @template = template
    @selectedPath = selectedPath

    atom.commands.add @element, 'core:cancel': ( e ) =>
      @close()

  createTemplatedFiles: ( e ) ->
    console.log @

  getFieldsFromTemplate: ( template ) ->
    fieldsArr = []

    processNodes = ( nodes ) ->
      fields = []
      for node in nodes
        if node.type == "FILE"
          regex = /(\[\{\[([a-zA-Z0-9]+)\]\}\])/g
          match = regex.exec( node.templateContent )
          while ( match != null )
            fieldsArr.push match
            match = regex.exec( node.templateContent )

        if (node.type == "FOLDER" or node.type == "GROUP") and node.items.length > 0
          processNodes( node.items )

    processNodes ( template )
    fieldsArr = _.uniq fieldsArr, ( a, b ) ->
      return a[2]

  viewForItem: ( item ) ->
    $$ ->
      @li =>
        @tag 'atom-text-editor', 'placeholder-text':item[2], mini:true

  populateFields: ( fields ) ->
    @fieldsList.empty()
    for field in fields
      itemView = $(@viewForItem(field))
      itemView.data('field-item-data', field)
      @fieldsList.append itemView

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this)
    @populateFields(@getFieldsFromTemplate([@template]))

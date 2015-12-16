{View, SelectListView, $$ } = require 'atom-space-pen-views'
{Emitter} = require 'atom'
CSON = require 'season'

module.exports =
class TemplateSelectorListView extends SelectListView
  selectedPath = null

  initialize: ({selectedPath}={}) ->
    super
    @setError(" ")
    @selectedPath = selectedPath

  viewForItem: ( item ) ->

    $$ ->
      @li =>
        @span item.displayName

  confirmed: ( item ) ->
    @trigger 'template-selected', item
    @close()

  cancelled: ->
    @close()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this)
    @focusFilterEditor()

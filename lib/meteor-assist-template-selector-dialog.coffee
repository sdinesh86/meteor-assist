{SelectListView, $$, $ } = require 'atom-space-pen-views'
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
        @span item

  populateList: ->
    super
    @list.empty()

    for key of @items
      item = @items[key]
      obj = {}
      obj[key] = item
      itemView = $(@viewForItem(key))
      itemView.data('select-list-item', obj)
      @list.append itemView

    @selectItemView(@list.find('li:first'))

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

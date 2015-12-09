{View, $, $$} = require 'atom-space-pen-views'
{Emitter} = require 'atom'
EditableLabelView = require './editable-label'

module.exports =

class TemplatesTreeView extends View

  constructor: ->
    super
    @emitter = new Emitter
    @addClass('ma-tree-view-wrapper')

  @content: ->
    @div =>
      @div class:'ma-tree-view-header', =>
        @div class:'btn-group', =>
          @button class:'btn icon icon-database', 'data-type':'GROUP', click:'onAddItemButtonClicked'
          @button class:'btn icon icon-file-directory', 'data-type':'FOLDER',click:'onAddItemButtonClicked'
          @button class:'btn icon icon-file-code', 'data-type':'FILE',click:'onAddItemButtonClicked'
      @div class:'select-list block', =>
        @ol class:'list-group', outlet:'list', =>

  initialize: ->
    # Subscribe to the event on the action buttons on the item
    @list.on 'click', 'li .action-buttons span', @onItemActionButtonClicked

    # Subscribe to the event when the item is clicked
    @list.on 'click', 'li', @onListItemClicked

  viewForItem: ( item ) ->
    self = @
    $$ ->
      iconClass = switch item.type
        when "GROUP" then 'icon icon-database'
        when "FOLDER" then 'icon icon-file-directory'
        when "FILE" then 'icon icon-file-code'

      createEditableLabel = =>
        temp = new EditableLabelView(  )
        temp.setText( item.displayName )
        temp.onLabelChanged (self.onListItemLabelChanged)
        temp

      @li =>
        @span class:'icon icon-chevron-right' if item.type == "GROUP" || item.type == "FOLDER"
        @span class:iconClass
        @subview 'item-title', createEditableLabel()
        @div class:'pull-right action-buttons', =>
          @span class:'icon icon-database text-highlight', 'data-type':'GROUP' if item.type == "GROUP" || item.type == "FOLDER"
          @span class:'icon icon-file-directory text-highlight', 'data-type':'FOLDER' if item.type == "GROUP" || item.type == "FOLDER"
          @span class:'icon icon-file-code text-highlight', 'data-type':'FILE' if item.type == "GROUP" || item.type == "FOLDER"
          @span class:'icon icon-remove-close text-highlight'
        @ol class:'list-group' if item.type == "GROUP" || item.type == "FOLDER"

  onListItemClicked: ( e ) =>
    listItem = if not $(e.target).is('li') then $(e.target).closest('li') else $(e.target)
    @selectListItemView( listItem )

  onItemActionButtonClicked: ( e ) =>
    if $(e.target).hasClass('icon-remove-close')
      @removeItem( $(e.target).closest('li') )
    else
      listItem = $(e.target).closest('li')
      list = listItem.children('ol.list-group')

      @addItem( {
        displayName: "#{$(e.target).data('type')} #{list.children().length}"
        type: $(e.target).data('type')
        }, list)
    e.preventDefault()
    false

  onAddItemButtonClicked: ( e ) =>
    @addItem {
      displayName: "#{$(e.target).data('type')} #{@list.children().length}"
      type: $(e.target).data('type')
    }

  onListItemLabelChanged: ( {newText, view} ) ->
    view.data('list-item-data').displayName = newText

  addItem: ( item, parent ) ->
    itemView = $(@viewForItem(item))
    itemView.data('list-item-data', item)

    if parent?
      parent.append(itemView)
    else
      @list.append(itemView)

    @emitter.emit 'item-added', itemView

    itemView

  getSelectedItem: ( ) ->
    if @list.find('.selected').length > 0 then @list.find('.selected') else null

  selectNextOrPrev: ( currSel ) ->
    next = currSel.next()
    prev = currSel.prev()

    if next.length > 0
      @selectListItemView next
    else if prev.length > 0
      @selectListItemView prev
    else
      @selectListItemView null

  removeItem: (item) ->

    if item.hasClass('selected')
      @selectNextOrPrev( item )

    item.remove()

  selectListItemView: ( view ) ->
    unless view?
      # Emitt Selection changed event
      @emitter.emit 'selection-changed', null
    else
      unless view.hasClass('selected')
        @list.find('.selected').removeClass('selected')
        view.addClass('selected')
        @emitter.emit 'selection-changed', view

  populateItems: ( items ) ->
    @list.empty()
    for item in items
      @addItem(item)

  readSettingsFile: ->


  deSerializeList: ( json ) ->
    if json.length > 0
      self = @
      @list.empty()
      parseNodes = ( nodes, parent ) ->
        for i in [0..(nodes.length-1)]
          node = nodes[i]
          li = self.addItem(node, parent)
          if node.items != undefined and node.items.length > 0
            parseNodes(node.items, li.children('ol.list-group') )

      parseNodes( json, @list)

  serializeList: ->
    serializeObject = []

    processListItem = ( node ) ->
      data = JSON.parse(JSON.stringify($(node).data('list-item-data')))
      $(node).find( '> ol.list-group > li').each ( ) ->
        if not data.hasOwnProperty('items')
          data.items = []
        data.items.push processListItem($(@))
      data

    @list.children('li').each ( ) ->
      serializeObject.push processListItem($(@))

    serializeObject

{View, $, $$} = require 'atom-space-pen-views'
Path = require 'path'

module.exports =

class MeteorAssistSelectListView extends View

  @content: ->
    @div class:'ma-tree-view-wrapper', =>
      @div class:'ma-tree-view-header', =>
        @div class:'btn-group', =>
          @button class:'btn icon icon-database', 'data-type':'GROUP', click:'onAddItemButtonClicked'
          @button class:'btn icon icon-file-directory', 'data-type':'FOLDER',click:'onAddItemButtonClicked'
          @button class:'btn icon icon-file-code', 'data-type':'FILE',click:'onAddItemButtonClicked'
      @div class:'select-list block', =>
        @ol class:'list-group', outlet:'list', =>


  # Public: Initialize the View
  #
  # Returns the [Description] as `undefined`.
  initialize: ->
    # Subscribe to the event on the action buttons on the item
    @list.on 'click', 'li .action-buttons span', @onListItemButtonClicked

    # Subscribe to the event when the item is clicked
    @list.on 'click', 'li', @onListItemClicked

    # Subscribe to the event when the item is clicked
    @list.on 'click', 'li span.dropdown-icon', ( e ) =>
      li = $(e.target).closest('li')
      list = li.children('ol.list-group')
      own = $(e.target)
      if own.hasClass('icon-chevron-down')
        list.slideUp(200)
        own.removeClass('icon-chevron-down').addClass('icon-chevron-right')
      else
        list.slideDown(200)
        own.removeClass('icon-chevron-right').addClass('icon-chevron-down')

    @list.on 'dblclick', 'li span.item-title', ( e ) =>
      spanTitle = $(e.target)
      editorTitle = spanTitle.next()
      editorTitle[0].getModel().setText(spanTitle.html())
      spanTitle.hide()
      editorTitle.show()
      editorTitle.focus()

    @list.on 'blur', 'li .item-title-editor', @cancelEditingTitle

    @list.on 'keydown', 'li .item-title-editor', ( e ) =>
      editorTitle = $(e.target)
      spanTitle = editorTitle.prev()
      type = spanTitle.closest('li').data('list-item-data').type
      newText = editorTitle[0].getModel().getText()

      if e.which == 13
        isEmptyString = newText == ""
        isFileName = not isEmptyString and ( Path.extname(newText) != "" and Path.extname(newText) != "." )

        if isEmptyString
          atom.notifications.addWarning('Error : File name should have an extention')

        if not isEmptyString
          if type == "FILE" and not isFileName
            atom.notifications.addWarning('Error : File name should have an extention')
          else
            spanTitle.html(newText)
            ext = Path.extname(newText)
            spanTitle.closest('li').data('list-item-data').displayName = newText
            spanTitle.closest('li').data('list-item-data').extension = ext
            editorTitle.hide()
            spanTitle.fadeIn(400)


  cancelEditingTitle: ( e ) =>
    editorTitle = $(e.target)
    spanTitle = editorTitle.prev()

    editorTitle.hide()
    spanTitle.show()

  # viewForItem: Generate the dom nodes for the given item
  #
  # * `item ` The Object representing the item as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  viewForItem: ( item ) ->
    $$ ->

      iconClass = switch item.type
        when "GROUP" then 'icon icon-database'
        when "FOLDER" then 'icon icon-file-directory'
        when "FILE" then 'icon icon-file-code'

      @li =>
        @span class:'icon icon-chevron-right dropdown-icon' if item.type == "GROUP" || item.type == "FOLDER"
        @span class:iconClass
        @div class:'editable-label inline-block', =>
          @span item.displayName, class:'item-title inline-block'
          @tag 'atom-text-editor', class:'item-title-editor', style:'display: none;', mini:true
        @div class:'pull-right action-buttons', =>
          @span class:'icon icon-database text-highlight', 'data-type':'GROUP' if item.type == "GROUP" || item.type == "FOLDER"
          @span class:'icon icon-file-directory text-highlight', 'data-type':'FOLDER' if item.type == "GROUP" || item.type == "FOLDER"
          @span class:'icon icon-file-code text-highlight', 'data-type':'FILE' if item.type == "GROUP" || item.type == "FOLDER"
          @span class:'icon icon-remove-close text-highlight'
        @ol class:'list-group' if item.type == "GROUP" || item.type == "FOLDER"

  # Public: Event for handelling the click for button
  #
  # * `e ` The jquery event as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  onAddItemButtonClicked: ( e ) =>

    # Get the type attribute from the clicked button
    type = $(e.target).data('type')

    # Public: [Description].
    item = {
      displayName: if type == "GROUP" || type == "FOLDER" then "#{type} #{@list.children().length}" else "#{type} #{@list.children().length}.ext"
      type: type
    }
    item.extension  = ".ext" if type is "FILE"
    item.templateContent  = "" if type is "FILE"

    @addItem item

  # onListItemButtonClicked: Event Handler for list item buttons
  #
  # Returns the [Description] as `undefined`.
  onListItemButtonClicked: ( e ) =>
    if $(e.target).hasClass('icon-remove-close')
      # If the clicked button has remove class then remove the current item from the list
      @removeItem( $(e.target).closest('li') )
    else
      # Get the 'li' element
      listItem = $(e.target).closest('li')
      list = listItem.children('ol.list-group')
      type = $(e.target).data('type')

      # Public: [Description].
      item = {
        displayName: if type == "GROUP" || type == "FOLDER" then "#{type} #{@list.children().length}" else "#{type} #{@list.children().length}.ext"
        type: type
      }

      item.extension  = ".ext" if type is "FILE"
      item.templateContent  = "" if type is "FILE"

      @addItem item, list

    e.preventDefault()
    false

  # populateItems: Populate the list with the items
  #
  # * `items ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  populateItems: ( json ) ->
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
    # @list.empty()
    # for item in items
    #   @addItem(item)


  # Public: Add the passed down item to Select List
  #
  # * `item ` The Item object with properties as {object}.
  #
  # Returns the [Description] as `undefined`.
  addItem: ( item, parent ) ->
    itemView = $(@viewForItem(item))
    itemView.data('list-item-data', item)

    if parent?
      parent.append(itemView)
    else
      @list.append(itemView)

    itemView

  # removeItem: Remove the selected item from the list
  #
  # * `item` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  removeItem: (item) ->
    # If the item to be remvoed is selected the change the selection
    if item.hasClass('selected')
      @selectNextOrPrev( item )

    item.remove()

  # selectNextOrPrev: Check if the prev or next item can be selected, and if yes then select it
  #
  # * `currSel ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  selectNextOrPrev: ( currSel ) ->
    next = currSel.next()
    prev = currSel.prev()

    if next.length > 0
      @selectListItemView next
    else if prev.length > 0
      @selectListItemView prev
    else
      @selectListItemView null

  # selectListItemView: Select the given Item
  #
  # * `view ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  selectListItemView: ( view ) ->
    unless view?
      # Emitt Selection changed event
      @trigger 'selection-changed', null
    else
      unless view.hasClass('selected')
        @list.find('.selected').removeClass('selected')
        view.addClass('selected')
        @trigger 'selection-changed', view

  # onListItemClicked: handler to list the list item when clicked
  #
  # * `e ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  onListItemClicked: ( e ) =>
    listItem = if not $(e.target).is('li') then $(e.target).closest('li') else $(e.target)
    @selectListItemView( listItem )

  # deSerializeList: Deserialize the list to a JSON object
  #
  # * `json ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
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

  # serializeList: Serialize the json object into list
  #
  # Returns the [Description] as `undefined`.
  serializeList: ->
    serializeObject = []

    processListItem = ( node ) ->
      console.log $(node).data('list-item-data')
      data = JSON.parse(JSON.stringify($(node).data('list-item-data')))
      data.items = []

      $(node).find( '> ol.list-group > li').each ( ) ->
        data.items.push processListItem($(@))
      data

    @list.children('li').each ( ) ->
      serializeObject.push processListItem($(@))

    serializeObject

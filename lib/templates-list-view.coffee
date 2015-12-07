{View, $, $$} = require 'atom-space-pen-views'
{Emitter} = require 'atom'
path = require 'path'

module.exports =
class TemplatesListView extends View
  constructor: ->
    super
    @emitter = new Emitter

  @content: ->
    @div class:'select-list', =>
      @ol class:'list-group', outlet:'list', =>

  initialize: ->

    @list.on 'click', 'li', ( e ) =>
      @selectItemView($(e.target).closest('li'))

    @list.on 'dblclick', 'li span.title-text', @editItemText
    @list.on 'blur', 'li atom-text-editor.title-edittext', @cancelEditItemText
    @list.on 'click', 'li .actions-button > span', @itemActionButtonClicked
    @list.on 'click', 'li span.dropdown-icon', (e) =>
      item = $(e.target).closest('li')
      subMenu = item.children('ol.list-group')
      subMenu.slideToggle(400)

    atom.commands.add @element, 'core:confirm': @confirmEditItemText

  onItemSelected: ( callback ) ->
    @emitter.on 'item-selected', callback

  onSelectionChanged: ( callback ) ->
    @emitter.on 'selection-changed', callback

  onFileNameChanged: (callback) ->
    @emitter.on 'file-name-changed', callback

  viewForItem: ({displayName, type, templateContent, extension}) ->
    $$ ->
      classType = switch type
        when 'GROUP' then 'icon icon-database'
        when 'FOLDER' then 'icon icon-file-directory'
        when 'FILE' then 'icon icon-file-code'

      @li =>
        @div class:'pull-right actions-button', =>
          @span class:'icon icon-database text-highlight', action:'create', type:'GROUP' if type == 'GROUP' or type == 'FOLDER'
          @span class:'icon icon-file-directory text-highlight', action:'create', type:'FOLDER' if type == 'GROUP' or type == 'FOLDER'
          @span class:'icon icon-file-code text-highlight', action:'create', type:'FILE' if type == 'GROUP' or type == 'FOLDER'
          @span class:'icon icon-x text-highlight', action:'delete'
        @span class:"icon icon-chevron-right text-highlight inline-block dropdown-icon" if type == 'GROUP' or type == 'FOLDER'
        @span displayName, class:"title-text #{classType}"
        @tag 'atom-text-editor', mini:true, class:'title-edittext inline-block', style:'display: none;'
        @ol class:'list-group block'

  editItemText: ( e ) =>
    own = $(e.target)
    item = own.closest('li')
    editText = own.next()

    own.hide()
    editText[0].model.setText(item.data('select-list-item').displayName)
    editText.fadeIn(400).focus()

  confirmEditItemText: (e) =>
    edtText = $(e.target)
    li = edtText.closest('li')
    titleSpan = edtText.prev()
    newVal = edtText[0].model.getText()

    data = li.data('select-list-item')
    data.displayName = newVal
    data["extension"] = path.extname(newVal)

    li.data('select-list-item', data)

    edtText.hide()
    titleSpan.html(newVal)
    titleSpan.fadeIn(400)
    @emitter.emit 'file-name-changed', li

  cancelEditItemText: ( e ) ->
    own = $(e.target)
    title = own.prev()
    own.hide()
    title.fadeIn(400)

  itemActionButtonClicked: ( e ) =>
    if $(e.target).attr('action') == 'create'
      item = $(e.target).closest('li')
      lg = item.children('ol.list-group')
      if lg?
        @addItem({displayName:'New Item', type:$(e.target).attr('type')}, lg)
    else if $(e.target).attr('action') == 'delete'
      item = $(e.target).closest('li')
      if item.hasClass('selected')
        newSel = if item.next().length > 0 then item.next() else item.prev()
        @selectItemView(newSel)
      item.remove()
      e.preventDefault()
    false

  getSelectedItem: ->
    @getSelectedItemView().data('select-list-item')

  getSelectedItemView: ->
    @list.find('li.selected')

  selectItemView: (view) ->
    if view.length
      oldSelection = @list.find('.selected')
      newItem = view
      unless oldSelection[0] == newItem[0]
        oldSelection.removeClass('selected')
        newItem.addClass('selected')
        @emitter.emit 'selection-changed', view
    else
      @emitter.emit 'selection-changed', null

  addItem: (item, parent) ->
    itemView = $(@viewForItem(item))
    itemView.data('select-list-item', item)
    if parent? and parent.hasClass('list-group')
      parent.append(itemView)
    else
      @list.append(itemView)
    itemView

  populateItems: ( json ) ->
    self = @
    @list.empty()
    parseNodes = ( nodes, parent ) ->
      for i in [0..(nodes.length-1)]
        node = nodes[i]
        li = self.addItem(node, parent)
        if node.items != undefined and node.items.length > 0
          parseNodes(node.items, li.children('ol.list-group') )

    parseNodes( json, @list)

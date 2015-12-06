{View, $, $$} = require 'atom-space-pen-views'
{Emitter} = require 'atom'

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

  editItemText: ( e ) =>
    own = $(e.target)
    item = own.closest('li')
    editText = own.next()

    own.hide()
    editText[0].model.setText(item.data('select-list-item').displayName)
    editText.fadeIn(400).focus()

  confirmEditItemText: (e) =>
    own = $(e.target)
    item = own.closest('li')
    title = own.prev()
    newVal = own[0].model.getText()
    own.hide()
    item.data('select-list-item').displayName = newVal
    title.html(newVal)
    title.fadeIn(400)

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
        @addItem({name:'item',displayName:'New Item', type:$(e.target).attr('type')}, lg)
    else if $(e.target).attr('action') == 'delete'
      item = $(e.target).closest('li')
      item.remove()
      e.preventDefault()
    false

  getSelectedItem: ->
    @getSelectedItemView().data('select-list-item')

  getSelectedItemView: ->
    @list.find('li.selected')

  selectItemView: (view) ->
    return unless view.length
    @list.find('.selected').removeClass('selected')
    view.addClass('selected')
    @emitter.emit 'item-selected', view

  viewForItem: ({name, displayName, type}) ->
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

  addItem: (item, parent) ->
    itemView = $(@viewForItem(item))
    itemView.data('select-list-item', item)
    if parent? and parent.hasClass('list-group')
      parent.append(itemView)
    else
      @list.append(itemView)

  populateItems: ->

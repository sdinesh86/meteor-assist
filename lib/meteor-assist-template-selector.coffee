{View, SelectListView, $$ } = require 'atom-space-pen-views'
{Emitter} = require 'atom'
CSON = require 'season'

module.exports =
class TemplateGenerator extends View

  @content: (params={}) ->
    @div =>
      @subview 'templateSelector', new TemplateSelectorListView()
      @div class:'fields-list', =>
        @ol class:'list-group' , outlet:'list', =>


  initialize: ->
    @templateSelector.onCancelled ( ) =>
      @hide()

    @templateSelector.onConfirmed ( item ) =>
      console.log item
      @templateSelector.hide()

  populateFieldsItem: ->
    @list.empty()

  hide: ->
    @panel.hide()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item:this)

    configFilePath = atom.config.get('meteor-assist.templatesFilePath')
    CSON.readFile configFilePath, ( err, json ) =>
       if json?
         @templateSelector.setItems ( json )
         @panel.show()
       else
         atom.notifications.addError("Error occured while trying to load the Templates list, please make sure that the config file exists and is valid")

    @templateSelector.focusFilterEditor()


  toggle:->
    if @panel?.isVisible()
      @cancel()
    else
      @show()

class TemplateSelectorListView extends SelectListView

  initialize: ->
    super
    @emitter = new Emitter
    @setError(" ")

  viewForItem: ( item ) ->

    $$ ->
      @li =>
        @span item.displayName


  onConfirmed: ( callback ) ->
    @emitter.on 'item-confirmed', callback

  onCancelled: ( callback ) ->
    @emitter.on 'cancelled', callback

  confirmed: ( item ) ->
    @emitter.emit 'item-confirmed', item

  cancelled: ->
    @emitter.emit 'cancelled'

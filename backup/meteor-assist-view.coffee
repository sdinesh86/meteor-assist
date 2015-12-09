{View, $, $$, SelectListView} = require 'atom-space-pen-views'
cson = require 'season'
{Emitter} = require 'atom'

module.exports =
class MeteorAssistView extends View
  @content: ->
    @div '', =>
      @subview 'templateSelector', new TemplateSelectionListView()
      @subview 'templatesProperties', new TemplatesPropertyNamesView()

  initialize: ->
    @templatesProperties.hide()
    @templateSelector.onConfirmed ( item ) =>
      @templateSelector.fadeOut(400)
      @templatesProperties.fadeIn(400)

  getTemplatesListCSON: ->
    configFilePath = atom.config.get 'meteor-assist.configFilePath'
    cson.readFile configFilePath, ( err, obj ) =>
      if obj?
        @templateSelector.setItems obj
        @templateSelector.populateList(  )

  hide: ->
    @panel.setItems([])
    @panel.hide()

  cancelled: ->
    @hide()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item:this)
    @getTemplatesListCSON()
    @panel.show()

  toggle: ->
    if @panel?.isVisible()
      @panel.hide()
    else
      @show()

class TemplateSelectionListView extends SelectListView

  initialize: ->
    super
    @emitter = new Emitter

  viewForItem: ( item ) ->
    $$ ->
      classType = switch item.type
        when 'GROUP' then 'icon icon-database'
        when 'FOLDER' then 'icon icon-file-directory'
        when 'FILE' then 'icon icon-file-code'

      @li =>
        @span class:classType
        @span item.displayName

  onConfirmed: ( callback) ->
    @emitter.on 'item-confirmed', callback

  confirmed: ( item ) ->
    @emitter.emit 'item-confirmed', item


class TemplatesPropertyNamesView extends View

  @content: ->
    @div class:'inset-panel', =>
      @div class:'block', =>
        @button '   Save   ', class:'btn btn-success icon icon-file-code'
        @button '    Cancel    ', class:'btn btn-error'
      @div class:'panel-body', =>

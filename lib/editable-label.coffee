{View, $} = require 'atom-space-pen-views'
{Emitter} = require 'atom'

module.exports =
class EditableLabelView extends View
  currentText: ""

  @content:  ->
    @div class:'editable-label inline-block', =>
      @span "Default Text", class:'title-label', outlet:'title_label'
      @tag 'atom-text-editor', class:'title-editbox', mini:true, outlet:'title_editbox'

  initialize: ->
    @emitter = new Emitter

    @title_label.on 'dblclick', ( e ) =>
      console.log $(e.target).html()
      $(e.target).hide()
      @title_editbox[0].getModel().setText($(e.target).html())
      @title_editbox.fadeIn(400)
      @title_editbox.focus()
      e.preventDefault()
      false

    @title_editbox.on 'blur', ( e ) =>
      $(e.target).hide()
      @title_label.fadeIn(400)

    @title_editbox.on 'keydown', ( e ) =>
      newText = @title_editbox[0].getModel().getText()
      if e.which == 13
        if newText != @title_label.html() and newText != ""
          @title_label.html(newText)
          $(e.target).hide()
          @title_label.fadeIn(400)
          @emitter.emit 'label-edit-changed', ({view:$(e.target).closest('li'), newText:newText})
        else if newText == ""
          $(e.target).hide()
          @title_label.fadeIn(400)

    @title_editbox.hide()
    @setText(@currentText)

  setText: ( text ) ->
    @title_label.html(text)

  getText: ->
    @title_label.html()

  onLabelChanged: ( callback ) ->
    @emitter.on 'label-edit-changed', callback

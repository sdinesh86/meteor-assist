{View, $} = require 'atom-space-pen-views'


module.exports =
class MeteorAssistTemplateEditorPanel extends View
  @content: ->
    @div 'ma-panel-heading', =>
    @div 'ma-panel-body', =>

  constructor: (args) ->
    # body...
    super
    @addClass('template-editor-panel')

  show: ->
    @panel ?= atom.workspace.addBottomPanel(item:this)
    @panel.show()

  toggle: ->
    if @panel?.isVisible()
      @panel.hide()
    else
      @show()

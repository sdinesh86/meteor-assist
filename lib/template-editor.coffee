{View, $, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class TemplateEditorView extends View
  @div 'template-editor-view-wrapper', =>
    @div 'block', =>
      @button 'Save ....', class:'btn btn-primary icon icon-file-code'

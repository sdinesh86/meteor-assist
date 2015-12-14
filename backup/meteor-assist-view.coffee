$ = require 'jquery'
fs = require 'fs-plus'
path = require 'path'

htmlstr = '<div class="meteor-assist-modal-wrapper select-list">
  <div class="header icon icon-file-add">
  Create a meteor template
  </div>
  <atom-text-editor mini id="template-name-input-text"></atom-text-editor>
  <div class="text-error error-message" >Nothing has been found!</div>
</div>'

module.exports =
class MeteorAssistEditorView
  constructor: ->
    @isShowing = false
    @elem = $(htmlstr)
    @templateInput = @elem.find('#template-name-input-text')
    @panel = null
    self = @
    @errorPanel = @elem.find( '.text-error.error-message' )

    @errorPanel.hide()

    atom.commands.add '.meteor-assist-modal-wrapper atom-text-editor',
      'core:confirm': ( event ) ->
        self.onConfirm(self.templateInput.get(0).getModel().getText())
    @templateInput.on 'blur', => @close()

  # Tear down any state and detach
  destroy: ->
    @elem.remove()

  getElement: ->
    @elem

  attach: ->
    @panel = atom.workspace.addModalPanel(item: @getElement())
    @templateInput.focus()

  close: ->
    @templateInput.get(0).getModel().setText('')
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    @isShowing = false

  show: ->
    unless @isShowing
      @attach()
      @isShowing = true

  showErrorMessage: ( msg ) ->
    @errorPanel.text( msg )
    @errorPanel.show()

  getFileContents: ( templateName, fileType ) ->
    switch fileType
      when "CSS" then ""
      when "SASS" then ""
      when "LESS" then ""
      when "HTML" then "<template name='#{templateName}'>\n\t\n</template>"
      when "JS" then "Template.#{templateName}.helpers({\n\t});\n\nTemplate.#{templateName}.events({\n\t});\n\nTemplate.#{templateName}.onRendered(function ( ){\n\t})"
      when "COFFEE" then "Template.#{templateName}.helpers \n\t\n\nTemplate.#{templateName}.events\n\t \n\nTemplate.#{templateName}.onRendered -> \n\t"
      else null

  onConfirm: ( templateName ) ->
    tvObj = null

    # close the window if the tree-view package doesnt exists
    @close() unless atom.packages.isPackageLoaded('tree-view')

    # get the tree view package
    tv = atom.packages.getLoadedPackage('tree-view')
    tvObj = tv.serialize()

    # close the modal incase the selectedPath is blank
    @close() unless tvObj.selectedPath

    regex = /^[a-zA-Z]+$/

    if templateName.match( regex ) == null
      @showErrorMessage( 'Invalid template name, template name cannot contain spaces / special characters like "-%$#@!"' )
      return

    $precompInFolder = atom.config.get('meteor-assist.precompInFolder')

    $targetFolder = if $precompInFolder then path.join(tvObj.selectedPath, templateName) else tvObj.selectedPath

    $filesArray =
      tpl:
        filename: path.join $targetFolder, "#{templateName}_template.html"
        format: "HTML"
      script:
        filename: path.join $targetFolder, switch atom.config.get('meteor-assist.scriptFormat')
          when "javascript" then "#{templateName}_script.js"
          when "coffeescript" then "#{templateName}_script.coffee"
          else "#{templateName}_script.js"
        format: switch atom.config.get('meteor-assist.scriptFormat')
          when "javascript" then "JS"
          when "coffeescript" then "COFFEE"
          else "JS"
      style:
        filename: path.join $targetFolder, switch atom.config.get('meteor-assist.stylesFormat')
          when "css" then "#{templateName}_style.css"
          when "less" then "#{templateName}_style.less"
          when "sass" then "#{templateName}_style.sass"
          else "#{templateName}_style.css"
        format: switch atom.config.get('meteor-assist.stylesFormat')
          when "css" then "CSS"
          when "less" then "LESS"
          when "sass" then "SASS"
          else "CSS"
    try
      # create fodler for template
      if $precompInFolder and fs.existsSync path.join(tvObj.selectedPath, templateName)
        @showErrorMessage 'Template folder with the same name already exists, please use a different name for the template'
        return
      else
        fs.makeTreeSync( $targetFolder )

      for key, val of $filesArray
        # console.log @getFileContents templateName, val.format
        doesExists = fs.isFileSync val.filename

        unless doesExists
          fs.writeFileSync val.filename, @getFileContents(templateName, val.format)
        else
          atom.notifications.addError( "Template file : #{val.filename} already exists" )

      @close()
    catch err
      atom.notifications.addError( err )
      @close()

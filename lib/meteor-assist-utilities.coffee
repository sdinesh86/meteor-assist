CSON = require 'season'
_ = require 'underscore'
Path = require 'path'

module.exports =

  getTemplatesDataFromFile: ->
    configFilePath = atom.config.get('meteor-assist.templatesFilePath')

    # Read the config file from and populate the list
    CSON.readFileSync configFilePath

  getExtensionFromFileName: ( fileName ) ->
    Path.extname(fileName)

  writeTemplatesDataToFile: ( data ) ->
    configFilePath = atom.config.get('meteor-assist.templatesFilePath')
    CSON.writeFileSync configFilePath, data

  typeIsArray: Array.isArray || ( value ) ->
    {}.toString.call(value) is '[object Array]'

  getFieldsFromTemplate: ( node ) ->
    fieldsArr = []
    regex = /(\[\{\[([a-zA-Z0-9]+)\]\}\])/g

    fileName = node
    templateContent = node.content

    # Check for fields in the Template content property
    match = regex.exec( templateContent )
    while ( match != null )
      fieldsArr.push match[2]
      match = regex.exec( templateContent )

    # Check for fields in the Template content property
    match = regex.exec( fileName )
    while ( match != null )
      fieldsArr.push match[2]
      match = regex.exec( fileName )

    _.flatten fieldsArr

  parseTemplate: ( template ) ->
    fields = []
    self = @
    iterateOverItem = ( items ) ->
      for key of items
        item = items[key]
        if typeof item == 'object'
          fields.push (self.getFieldsFromTemplate(item))
          iterateOverItem item

    iterateOverItem template
    console.log fields
    fields

CSON = require 'season'

module.exports =

  getTemplatesDataFromFile: ->
    configFilePath = atom.config.get('meteor-assist.templatesFilePath')

    # Read the config file from and populate the list
    CSON.readFileSync configFilePath

  writeTemplatesDataToFile: ( data ) ->
    configFilePath = atom.config.get('meteor-assist.templatesFilePath')
    CSON.writeFileSync configFilePath, data

fs = require 'fs-plus'

module.exports = MeteorAssistUtility =
class MeteorAssistUtility

  constructor: (args) ->
    # body...

  @isConfigFileExists: ->
    filePath = atom.config.get('meteor-assist.configFilePath')
    isFile = fs.isFileSync filePath
    isFile

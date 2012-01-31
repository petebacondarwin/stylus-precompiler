utils = require("kanso-utils/utils")
pathUtil = require('path')
attachments = require('kanso-utils/attachments')
precompiler = require('kanso-precompiler-base')
stylusCompiler = require('stylus')

module.exports =
  after: "attachments"
  run: (root, path, settings, doc, callback) ->
    stylusPaths = settings["stylus"]?["compile"]    
    compression = settings["stylus"]?["compress"] ? ""
    # Check the settings are valid
    unless stylusPaths?
      console.log "No stylus settings found - you should provide a stylus/compile setting"
      return callback(null, doc)
    

    compile_stylus = (filename, callback) ->
      # Make template filename relative and Strip off the extension
      name = utils.relpath(filename, path).replace(/\.styl$/, ".css")
      console.log "Compiling Styl Template: " + name      

      # Run the stylus compiler
      stylusCompiler(
        fs.readFileSync(filename, 'utf8'),
        compress: compression
      )
      # Allow files from the same folder as the file to be imported 
      .include(pathUtil.dirname(filename))
      # Render the new css contents
      .render((err, css) ->
        # Add the rendered css to the design document as an attachment
        attachments.add(doc, name, name, css)
        # Callback to let processPaths know that whether the css was generated successfully
        callback(err)
      )

    console.log "Running Stylus pre-compiler"

    # Extract the template paths from the settings
    stylusPaths = precompiler.normalizePaths(stylusPaths, path)

    # Run processTemplate, asynchronously, on each of the files that match the given pattern, in the given paths 
    precompiler.processPaths(stylusPaths, /.*\.styl$/i, compile_stylus, (err)-> callback(err, doc))

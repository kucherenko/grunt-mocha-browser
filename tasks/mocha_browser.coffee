module.exports = (grunt) ->
  util = grunt.util
  _ = util._
  path = require("path")
  exists = grunt.file.exists

  grunt.registerMultiTask "mocha_browser", "Mocha test suite for browser.", ->
    
    # Merge options
    options = @options(
      reporter: "spec"
      
      # Non file urls to test
      urls: []
    )
    files = @filesSrc
    args = []
    binPath = ".bin/mocha-browser" + ((if process.platform is "win32" then ".cmd" else ""))
    mocha_browser_path = path.join(__dirname, "..", "/node_modules/", binPath)
    urls = options.urls.concat(@filesSrc)
    done = @async()
    errors = 0
    results = ""
    output = options.output or false
    
    unless exists(mocha_browser_path)
      i = module.paths.length
      bin = undefined
      while i--
        bin = path.join(module.paths[i], binPath)
        if exists(bin)
          mocha_browser_path = bin
          break
    grunt.fail.warn "Unable to find mocha_browser."  unless exists(mocha_browser_path)
    
    _.each _.omit(options, "urls", "output"), (value, key) ->
      sw = ((if key.length > 1 then "--" else "-")) + key
      value = [value]  unless _.isArray(value)
      _.each value, (value) ->
        args.push [sw, value.toString()]


    util.async.forEachSeries urls, ((f, next) ->
      mocha_browser = grunt.util.spawn(
        cmd: mocha_browser_path
        args: _.flatten([f].concat(args))
      , (error, result, code) ->
        console.log result.stdout if options.reporter isnt 'html-cov'
        next()
      )
      mocha_browser.stderr.pipe process.stderr
      
      # Append output to be written to a file
      if output
        mocha_browser.stdout.on "data", (data) ->
          results += String(data.toString())

      mocha_browser.on "exit", (code) ->
        grunt.fail.warn "mocha_browser isn't installed"  if code is 127
        errors += code

    ), ->
      if not output and errors > 0
        grunt.fail.warn errors + " tests failed"
      else if output
        grunt.file.write output, results
        grunt.log.writeln "File #{output} created."
      done()


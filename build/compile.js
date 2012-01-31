(function() {
  var attachments, pathUtil, precompiler, stylusCompiler, utils;

  utils = require("kanso-utils/utils");

  pathUtil = require('path');

  attachments = require('kanso-utils/attachments');

  precompiler = require('kanso-precompiler-base');

  stylusCompiler = require('stylus');

  module.exports = {
    after: "attachments",
    run: function(root, path, settings, doc, callback) {
      var compile_stylus, compression, stylusPaths, _ref, _ref2, _ref3;
      stylusPaths = (_ref = settings["stylus"]) != null ? _ref["compile"] : void 0;
      compression = (_ref2 = (_ref3 = settings["stylus"]) != null ? _ref3["compress"] : void 0) != null ? _ref2 : "";
      if (stylusPaths == null) {
        console.log("No stylus settings found - you should provide a stylus/compile setting");
        return callback(null, doc);
      }
      compile_stylus = function(filename, callback) {
        var name;
        name = utils.relpath(filename, path).replace(/\.styl$/, ".css");
        console.log("Compiling Styl Template: " + name);
        return stylusCompiler(fs.readFileSync(filename, 'utf8'), {
          compress: compression
        }).include(pathUtil.dirname(filename)).render(function(err, css) {
          attachments.add(doc, name, name, css);
          return callback(err);
        });
      };
      console.log("Running Stylus pre-compiler");
      stylusPaths = precompiler.normalizePaths(stylusPaths, path);
      return precompiler.processPaths(stylusPaths, /.*\.styl$/i, compile_stylus, function(err) {
        return callback(err, doc);
      });
    }
  };

}).call(this);

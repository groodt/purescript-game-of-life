module.exports = function(grunt) {

  "use strict";

  grunt.initConfig({

    srcFiles: ["src/**/*.purs", "bower_components/**/src/**/*.purs"],

    psc: {
      options: {
        main: "Main",
        modules: ["Main"]
      },
      all: {
        src: ["<%=srcFiles%>"],
        dest: "dist/Main.js"
      },
      tests: {
        options: {
          module: ["Main"],
          main: true
        },
        src: ["tests/Main.purs", "<%=srcFiles%>"],
        dest: "dist/tests.js"
      }
    },

    execute: {
      tests: {
        src: "dist/tests.js"
      }
    },

    dotPsci: ["<%=srcFiles%>"]
  });

  grunt.loadNpmTasks("grunt-purescript");
  grunt.loadNpmTasks("grunt-execute");

  grunt.registerTask("build", ["psc:all", "dotPsci"]);
  grunt.registerTask("test", ["build", "psc:tests", "execute:tests"]);
  
  grunt.registerTask("default", ["psc:all", "dotPsci"]);
};

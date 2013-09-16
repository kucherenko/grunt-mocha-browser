grunt-mocha-browser
===================

Example of code coverage reporter for tests with mocha_browser:

    mocha_browser:
      all:
        options:
          output: ".tmp/test/coverage.html"
          reporter: 'html-cov'
          urls: ["http://localhost:<%= connect.options.port %>/test.html"]

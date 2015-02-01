# PureScript Game of Life

Conway's Game of Life in PureScript rendering to HTML5 Canvas.

## Building

    npm install
    bower update
    grunt


## Problems

The dependency on purescript-requestanimationframe prevents the tests from running. I need to figure out a good solution to this, since I would like to learn QuickCheck. I guess one solution could be to have a completely independent module without this dependency and write tests for pure code. Another solution I can think of is to somehow bring PhantomJS into the build for the test runs.

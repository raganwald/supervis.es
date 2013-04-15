# `supervis.es`

This is some example code that demonstrates extending the `sequence` method that is common to functional programming to absorb some monadic abstractions.

Please use [Github Issues](https://github.com/raganwald/supervis.es/issues) or comment on [Commits](https://github.com/raganwald/supervis.es/commits/master) to provide feedback. All thoughts are welcome.

### yak-shaving

The canonical source code is `coffee-src/supervis.es.coffee`. The code is tested using `npm test`, and a `pretest` script compiles the CoffeeScript to JavaScript in `lib/supervis.es.js`. `jasmine-node` then interprets the specs in the `spec` folder (they're also written in CoffeeScript).

To try it, you'll need node, jasmine-node, CoffeeScript, and their respective dependencies.

### code organization

The key function is `sequence`. In naïve form, `sequence` pipelines a value through a series of unary functions:

    plusOne = (n) -> n + 1
    double = (n) -> n * 2
    
    sequence(plusOne, double, double)(1)
      #=> 8

In this library, there is an additional mode. If the first argument to `sequence` is an instance of `Monad`, then `sequence` will use the Monad to wrap and unwrap values along the way.

Actually, this is always true: If the first argument isn't a Monad instance, `sequence` uses the `Identity` monad.

At this time, I've coded up:

1. Identity
2. Maybe
3. Writer
4. List
5. Promise

The `Promise` monad wraps a ridiculously simple `Promise` implementation. Errors fall through much like the Maybe monad.

### feedback wanted

Yes please!

* File a [Github Issue](https://github.com/raganwald/supervis.es/issues)
* Comment on a [Commit](https://github.com/raganwald/supervis.es/commits/master) 
* [Fork this](https://github.com/raganwald/supervis.es/fork_select) and issue a Pull Request

Thanks!
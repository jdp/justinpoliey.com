% Make for Front-end Development

If you're doing front-end development right now, you're probably using some kind of build tool to help you perform the repetitive tasks associated with it. Things like concatenating CSS files. Compiling CoffeeScript or Handlebars templates to JavaScript. Minifiying that JavaScript. There are a bunch of tools available to ease that drudgery, but seemingly overlooked is the venerable **make**. I want to show you that it and its ideas are still relevant in software development, and that it can be a powerful addition to your toolbox.

This isn't intended to be a full-on **make** tutorial, instead it's meant to get you familiar with it, to maybe introduce you to a new way of thinking, and to help you navigate projects in other areas of computing (not just dev) that might use it. By getting familiar with existing tools, through learning how they work and how to use them, you can better understand the decisions that went into the new tools and maybe incorporate some forgotten ideas into your own projects.

## What is make, really?

**Make** is a command-line tool that builds files from other files. Pretty simple. A lot of tasks fit perfectly into that model, and there are a lot of tools that can perform those tasks. What distinguishes it from other tools is how it accomplishes them. Where other tools might encourage a procedural way of thinking, **make** encourages a declarative and rule-based approach. That approach, in conjunction with shell integration, make it a very powerful and concise way to accomplish these tasks.

### So how do I use it?

When you run `make`, it searches the current directory for a file called a *makefile*, typically named `Makefile`. Where other build tools might process named lists of procedural steps to execute, **make** organizes its tasks into *rules*. The manual has a nice and compact section describing [what a rule looks like](http://www.gnu.org/software/make/manual/make.html#Rule-Introduction), but I'll include the syntax reference here:

```
target ... : prerequisites ...
    recipe
    ...
    ...
```

Rules are made up of *targets*, their dependencies (*prerequisites*), and steps (*recipes*) for resolving those dependencies. The targets and their prerequisites are typically files, and the recipes describe the steps to generate the targets from the prerequisites. What makes this approach so useful is that one target can be a prerequisite of another, and **make** implicitly figures out how and when to resolve them. The recipes are just shell commands, and are only invoked when necessary.

You can read more about [how **make** processes makefiles](http://www.gnu.org/software/make/manual/make.html#How-Make-Works) in the manual.

## Building a Simple App

Let's look at a small hypothetical app, one that consists of a model, a view, and a controller. Each has it's own JavaScript file, and for deployment we package it up into `app.js`. Its makefile might look like this:

``` makefile
app.js: model.js view.js controller.js
    cat $^ > $@
```

These 2 lines are pretty dense, so let's look piece by piece. The first line specifies the target and its prerequisites. Our target is `app.js`, and its prerequisites are `model.js`, `view.js`, and `controller.js`. If `app.js` does not exist, or if any of the prerequisites have been modified since the last time `app.js` was generated, **make** will run the recipe. In this example, the recipe is just a single command, `cat`. The `$^` *automatic variable* contains the list of prerequisites for the target, and the `$@` automatic variable contains the target. They are called automatic variables because **make** automatically sets them inside of recipes. You can read more about them and the other variables [in the manual](http://www.gnu.org/software/make/manual/make.html#Automatic-Variables). If we expand the variables in the recipe, it will look something like this when it's run:

``` shell
cat model.js view.js controller.js > app.js
```

The `cat` command concatenates files and prints them to standard output, but we use an [output redirect](http://www.gnu.org/software/bash/manual/html_node/Redirections.html) to print to the file `app.js` instead. If you're already familiar with shell syntax this example is trivial, but reinforces the idea that recipes are just shell commands.

### Porting Our App to CoffeeScript

Now imagine that we've ported our little app to CoffeeScript. We've kept our file structure, the code is tight and idiomatic, and we've even updated the makefile. It looks like this now. What's going on?

``` makefile
COFFEE = model.coffee view.coffee controller.coffee
JS = $(COFFEE:.coffee=.js)  # model.js view.js controller.js

app.js: $(JS)
    cat $^ > $@

$(JS): $(COFFEE)
    coffee -c $^
```

There's some new stuff in here, so again we'll go section by section.

The first section contains a couple [variable declarations](http://www.gnu.org/software/make/manual/make.html#Using-Variables), with the `COFFEE` variable just being a list of our CoffeeScript source files. The `JS` variable is a [substitution reference](http://www.gnu.org/software/make/manual/make.html#Substitution-Refs), and has the result of replacing all the .coffee suffixes in the `COFFEE` variable with .js suffixes.

The second section and first rule is a cleaned-up version of the rule from our first makefile. It gives the target as the concatenated `app.js`, and its prerequisites as the JavaScript source files. This time though, instead of listing the file names explicitly, we [reference](http://www.gnu.org/software/make/manual/make.html#Reference) the `JS` variable. We've DRY'd this rule up, but how does **make** know how to build the JavaScript files from the CoffeeScript ones? It's handled in the next rule, where we have the prerequisite `JS` of this rule as the target of the next one. By allowing us to specify prerequisites of one rule as targets of others, we can create complex dependency graphs that **make** can resolve.

The second rule provides a way for the `JS` target to be generated frm the `COFFEE` prerequisite. In other words, it provides a way for JavaScript files that are needed by our `app.js` file to be generated from our CoffeeScript files. If the JavaScript files don't exist, or the CoffeeScript files have been modified since the last time the JavaScript files were generated, the recipe will run.

### Upgrading Our Views to Handlebars

After adding some more features, our little app is not so little anymore. We've grown in complexity a bit and we're now using Handlebars templates for the views. One of the nice features of Handlebars is its ability to [precompile templates to JavaScript](http://handlebarsjs.com/precompilation.html), so we're going to include that in our makefile. Here's how it looks now:

``` makefile
COFFEE = model.coffee view.coffee controller.coffee
HANDLEBARS = forms.handlebars profile.handlebars feed.handlebars
JS = $(COFFEE:.coffee=.js) $(HANDLEBARS:.handlebars=.js)

app.js: $(JS)
    cat $^ > $@
    
$(JS): $(COFFEE) $(HANDLEBARS)

%.js: %.coffee
    coffee -c $<
    
%.js: %.handlebars
    handlebars $< -f $@
```

The first thing we should note is that we can put more than one substitution reference in a variable declaration, and that really simplifies our `JS` variable. It now contains all the files from the `COFFEE` and `HANDLEBARS` variables, with their file suffixes replaced with .js.

Following that, we have the concatenation rule again. To generate the concatenated `app.js`, we need the resultant JavaScript files from our CoffeeScript and Handlebars sources. Nothing really new here, let's move on.

The most significant change to the makefile is that our rule for generating JavaScript. The `JS` target is the same, but now it has two prerequisites: `COFFEE` and `HANDLEBARS`. A change to either of these prerequisites will cause the JavaScript files in the target to get generated again, but how? Where is the recipe for this rule? It turns out that **make** allows for empty recipes so that targets and their prerequisites can be specified while deferring their recipes to other rules. Some of those other possible rules are [pattern rules](http://www.gnu.org/software/make/manual/make.html#Pattern-Rules). A pattern rule lets us have an implicit rule for generating targets from prerequisites with matching names. Our first pattern rule specifies how to generate a JavaScript file from a CoffeeScript file. If we need a target `foo.js` and we have a `foo.coffee`, **make** can use the recipe from a pattern rule that matches. In this case we invoke the `coffee` command, with a new automatic variable: `$<`. This variable contains just the first prerequisite. That is to say, if `$^` is a list of prerequisites, then `$<` is the first element of the list. We also define a pattern rule for handling Handlebars sources that works similarly.

## Handling Other Tasks

As we've worked on our app, we've noticed that not all tasks are easily or clearly defined in terms of target files and their prequisites. For example, how do we clean up our working directory after building our app? It's littered with JavaScript files that we don't need to keep around. We can address cases like this with [phony targets](http://www.gnu.org/software/make/manual/make.html#Phony-Targets), which are similar to tasks in other systems. They're just named recipes to execute on request. Here's our updated makefile with a `clean` task to remove our unnecessary JavaScript files:

``` makefile
COFFEE = model.coffee view.coffee controller.coffee
HANDLEBARS = forms.handlebars profile.handlebars feed.handlebars
JS = $(COFFEE:.coffee=.js) $(HANDLEBARS:.handlebars=.js)
APP = app.js

$(APP): $(JS)
    cat $^ > $@
    
$(JS): $(COFFEE) $(HANDLEBARS)

%.js: %.coffee
    coffee -c $<
    
%.js: %.handlebars
    handlebars $< -f $@
    
.PHONY: clean
clean:
    rm $(APP) $(JS)
```

## Onward From Here

By now, you should be able to add some other features to the makefile we've built up. As an exercise, you can try to add rules to compress the JavaScript with [UglifyJS](http://lisperator.net/uglifyjs/) or the [Closure Compiler](https://developers.google.com/closure/compiler/). Add a phony target to start a web server, or to watch source files for changes and re-run **make** automatically. Maybe you won't use **make** in your day-to-day work, but that's okay, because it might influence the way you organize your other build processes. If you decide to give it a permanent place in your toolbox though, you'll find it well-suited for all sorts of computing tasks, including those outside of software development.

% Static Sites with make

This website is built with a simple static site generator.
Like most of the other systems,
pages are edited in Markdown and then later emitted as HTML.
The cool thing about this one is that probably have it installed already ---
it's just `make(1)`!
From the [homepage][make-homepage]:

> Make is a tool which controls the generation of executables and other non-source files of a program from the program's source files.

It is traditionally used for building programs written in C
and other languages that generate executables.
Make is more widely applicable than that though;
it can thought of more generally as a dependency resolution system.
Given some targets and some rules for resolving their dependencies,
make can figure out which dependencies are already resolved
and then run steps to resolve the remaining ones.

In the context of using `make` as a static site generator,
the target is a website whose dependencies are HTML files,
and the dependencies of those HTML files are their respective source Markdown files.
We can give some rules for turning the Markdown into HTML and HTML into a site,
and `make` will take care of the rest.


One of the best things about using `make` to accomplish this task
and ones like it
is how it fits in well with the "[Unix is the IDE][unix-as-ide]" philosophy.
It's also nice to not have to use programming language-specific package managers to install the system.
I can just drop a Makefile in my dang project directory and be done with it.

### My Workflow

In one short Makefile the whole workflow for building the site is defined.
This website is built entirely with `make`, the [Makefile][site-makefile] is available to check out.
It has targets for building the site,
cleaning out generated HTML files,
and deploying the site to a remote host.

When I want to build the site,
I run `make`.

When I'm ready to upload to my remote host,
I run `make deploy`.

I'm not sure that it could be easier,
but I am sure that it shouldn't be harder.
This method uses standard tools
except for the command-line Markdown compiler [Pandoc][pandoc].
The Makefile can be easily adapted to use another templating language though,
so you could probably go totally native and use a [little AWK-based template language][werc]
if you were so inclined.

### Takeaway

While this workflow works great for me,
there are are some shortcomings.
It's not immediately useful for managing something like a blog.
Not that it can't be done,
it's just not part of my use case yet.

[make-homepage]: http://www.gnu.org/software/make/
[make-makefiles]: http://www.gnu.org/software/make/manual/html_node/Introduction.html#Introduction
[jekyll]: http://jekyllrb.com
[pandoc]: http://johnmacfarlane.net/pandoc
[site-makefile]: https://github.com/jdp/justinpoliey.com/blob/master/Makefile
[unix-as-ide]: http://blog.sanctum.geek.nz/unix-as-ide-introduction/
[werc]: http://werc.cat-v.org/

---
title: remake
author: Justin Poliey
---

Remake is a tiny pattern I use to automatically rebuild projects when their source files change.
It’s a simple recipe built around [entr][entr],
a utility that watches files for changes and runs a command when they do.

The intent is to re-run [make][make] when it detects a change in the files that it’s watching.
Here it is:

``` bash
while sleep 1; do ls $* | entr -d make; done
```

The magic is in the `-d` switch: `entr` will exit if it detects modifications in any of the directories of the files it is watching.
The outer while loop starts it back up again with the new list of files.

It’s a pattern I use a lot.
I even use it to rebuild this site—including this page as I write it:
t’s also works great as a `watch` process in a Procfile,
like if you’re compiling ES6 sources:

``` Procfile
watch: while true; do ls src/*.js | entr -d make; done
```

[entr]: http://entrproject.org/
[make]: http://www.gnu.org/software/make/

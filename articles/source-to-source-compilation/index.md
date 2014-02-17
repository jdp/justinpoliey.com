% Source to Source Compilation

The idea of cross-compiling languages isn't particularly new.
Various Lisp implementations have been source-to-source translations to host languages for decades,
and the original C++ compiler simply emitted C rather than object code.
The newest batch of source-translated languages,
like [CoffeeScript][coffee-script],
[Haml][haml],
and [Sass][sass],
have gained widespread acceptance by both hobbyists and professionals because they are useful and usable tools.
I want to show by example the steps involved in developing these languages while hopefully giving you a very small peek behind the curtain.

In the examples, we'll be working toward compiling [Brainfuck][brainfuck] to standard C source.
I picked C as the target language because Brainfuck instructions have well-defined analogous expressions in C.
Knowledge of C will be helpful,
but not essential to understanding the process.

### Lexical Analysis

The first phase of building a compiler is lexical analysis.
Also known as _lexing_, _scanning_, or _tokenizing_,
it is the process of breaking up the input source into _tokens_.
A token is some atomic unit of code, be it an identifier like `myFunction` or `$someVariable`,
an operator like `+` or `*`, or any other lexical element.
Brainfuck has a very simple structure:
each character is a token.
This allows our `tokenize` function to be pretty straightforward:

``` python
def tokenize(source):
    return list(source)
```

Our tokenizer simply returns a list of tokens,
and in the case of Brainfuck,
this ends up being a list of the characters of the input string.
This is truly about as simple as it gets.
Most languages will not be tokenized so easily,
but tools exist to help build more powerful tokenizers[^lexers].

### Syntactic Analysis

Syntactic analysis,
otherwise known as _parsing_,
is the process of analyzing the input tokens and determining whether or not they match the defined syntax rules of the language.
A parser also usually builds a nested data structure that represents the underlying structure of the code,
which is easier to work with inside of the rest of the program than a flat list of tokens.
The nested structure is typically referred to as the _syntax tree_.

Brainfuck only has a couple syntax rules:

* All tokens except `+` `-` `<` `>` `,` `.` `[` `]` are ignored
* An opening brace `[` must have a matching closing brace `]`

Our parser should enforce these syntax rules,
and return a syntax tree when a parse is successful.

``` python
def parse(tokens):
    depth = 0
    ast = []
    stack = [ast]
    node = ast
    for token in tokens:
        if token == '[':
            node.append([])
            stack.append(node)
            node = node[-1]
            depth += 1
        elif token == ']':
            if depth == 0:
                raise SyntaxError("Unmatched closing bracket")
            node = stack.pop()
            depth -= 1
        elif token in "+-<>,.":
            node.append(token)
    if not depth == 0:
        raise SyntaxError("Unmatched opening bracket")
    return ast
```

Our `parse` function builds and returns a nested list structure representing our syntax tree inside the variable `ast`.
Our parser will also guarantee that the brackets are balanced,
and that only recognized instructions will be added to the tree.

As an example,
let's tokenize and parse one of the canonical Brainfuck examples:
`,[.,]`.
This is a simple implementation of `cat(1)`,
echoing any input received.

``` python
tokens = tokenize(",[.,]")
# tokens now contains [",", "[", ".", ",", "]"]
ast = parse(tokens)
# ast now contains [",", [".", ","]]
```

Notice how the `[` and `]` tokens weren't preserved in the tree contained in `ast`.
The loop is implicitly represented as a list of instructions and the token markers are no longer needed.

### Compiling

Now that we have a syntax tree,
we can traverse it and emit equivalent C source.
Brainfuck to C has a nearly 1:1 mapping aside from the necessary prolog and epilog,
so a simple top-down recursive function will suffice to return the meat of the generated code.

``` python
def compile_to_c(tree):
    buf = ""
    for node in tree:
        if isinstance(node, list):
            buf += "while (*p) { "
            buf += compile_to_c(node)
            buf += "} "
        elif node == '+':
            buf += "++*p; "
        elif node == '-':
            buf += "--*p; "
        elif node == '>':
            buf += "++p; "
        elif node == '<':
            buf += "--p; "
        elif node == ",":
            buf += "*p = getchar(); "
        elif node == ".":
            buf += "putchar(*p); "
    return buf
```

The process is pretty straightforward,
because no code needs to be relocated or transformed past this point.
Brainfuck loops are recursively translated to their equivalent C loops,
and instructions are translated to their C expression analogues.

As noted earlier,
the code generated by `compile_to_c` won't compile on its own,
it needs some extra boilerplate code.
Here's a quick and easy way to do it:

``` python
print "#include <stdio.h>"
print "#include <stdlib.h>"
print "int main(int argc, char **argv) {"
print "  int *p = (int *)malloc(30000 * sizeof(int));"
print " ", compile_to_c(ast)
print "  return 0;"
print "}"
```

Now the output from our program will be valid C source.
So let's see what the compiled C code looks like from our original example program,
`,[.,]`:

``` c
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char **argv) {
  int *p = (int *)malloc(30000 * sizeof(int));
  *p = getchar(); while (*p) { putchar(*p); *p = getchar(); } 
  return 0;
}
```

If you were to compile and run this program it would echo everything you type.

### Next Steps

A slightly expanded version of the source code is available [as a Gist][bf2c-gist],
along with "Hello World" in Brainfuck.
To test it out,
download bfc.py and hello.bf  and then run this in your terminal:

``` bash
# you will be greeted with a familiar message
python bfc.py hello.bf | gcc -xc -
./a.out
```

This has been a _very_ oversimplified overview of how languages are processed,
but each step is a very concrete step in the creation of a programming language.
Really,
most languages share the same first steps and the difference lies in whether they are interpeted or compiled after the syntax tree has been built.
Exploring the other routes we could have taken with our syntax tree is an article for another time.

#### Update 2012-05-25

The term _transpiler_ seems to be unpopular among programmers. I have removed references to it.

#### Update 2013-08-19

I re-posted this from [the original blog post][original-post] to my website.

[^lexers]: For JavaScript, you can check out [Jison](), which has [it's own lexical analyzer][jison-lexer]. The system is modeled after the [Flex and Bison][flex-bison] toolchain.

[bf2c-gist]: https://gist.github.com/2237916
[brainfuck]: http://www.muppetlabs.com/~breadbox/bf/
[coffee-script]: http://coffeescript.org/
[flex-bison]: http://dinosaur.compilertools.net/
[haml]: http://haml-lang.com/
[jison]: http://zaach.github.io/jison/
[jison-lexer]: http://zaach.github.io/jison/docs/#lexical-analysis
[original-post]: http://blog.justinpoliey.com/transpiling-languages-an-intro-with-brainfuck.html
[sass]: http://sass-lang.com/
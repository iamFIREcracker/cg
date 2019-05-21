# cg

Guess commands to run from stdin, and print them to stdout.

# Background

Few years ago I stumbled upon [fpp](https://facebook.github.io/PathPicker),
a nice utility that would scan its input looking for possible pathnames, and
present you with a terminal UI to select which ones to open / send to an
external command; in a nut-shell, the
[urlview](https://github.com/sigpipe/urlview) for local files.

Wouldn't it be nice if there was a similar program that could guess which
command to run next, by looking at its input?  For example, you pipe `git log
-n ...`'s output into it, and it would output a bunch of "git show $sha1", "git show
$sha2", "git show $sha3" lines (one per log entry); or you pipe into it `ps
aux`'s output, and it would ask you which process to kill.

_enters `cg`.._

# Install

Differently from the other _2-letter-named_ command line utilities (i.e.
[cb](https://github.com/iamFIREcracker/cb),
[br](https://github.com/iamFIREcracker/br)) I have created in the past (pure
Bash scripts), `cg` is written in Common Lisp (stop it already!), so getting
your hands on it might not be as easy as you hoped it would, especially if
it's the first time you hear about Common Lisp.

Anyway, you have to options:

- Compile binary from sources
- Download a pre-compiled binary

## Compile

- Get yourself a [SBCL](http://www.sbcl.org/) -- apologies, it's the only Common
  Lips implementation that I tested this with, but hopefully none of those 30
  locs I managed to put together will be incompatible with other Common Lisp
  implementations
- Get yourself a [Quicklisp](https://www.quicklisp.org/beta/)
- Clone this repo
- Run `make`

If everything run smoothly, a shiny little `cg` should have appeared under
'$cgrepo/bin/'; if not then, you can try downloading one of the pre-compiled
binaries.

## Download

Each new tag ships with pre-compiled binaries for:

- Linux (tested on: Ubuntu 18.04 x64)
- macOS (tested on: Sierra)
- Windwos (tested on: Cygwin, MINGW, and LWM)

You can manually download which one you need, or you can run the following:

    ./download

It will guess your OS, download the pre-compiled binary, place it inside 'bin',
and make it executable.

# Usage

    > cg -h
    Guess commands to run from stdin, and print them to stdout.

    Available options:
      -h, --help               print the help text and exit
      -v, --version            print the version and exit
      -d, --debug              parse the RC file and exit

Using `cg` is really simple: you just pipe some text into it, and it will
output some commands you most likely would want to run next:

    > git l
    224d33a Fix some copy-pasta (HEAD -> master, origin/master) (by Matteo Landi)
    6fb3f7b Add support for multi item selection (by Matteo Landi)
    56c332c Do not specify sbcl full path (by Matteo Landi)
    ...

    > g l | cg
    git show '224d33a' # Fix some copy-pasta (HEAD -> master, origin/master) (by Matteo Landi)
    git show '6fb3f7b' # Add support for multi item selection (by Matteo Landi)
    git show '56c332c' # Do not specify sbcl full path (by Matteo Landi)
    ...

But first, you will have to teach `cg` how to guess commands.

While starting up, `cg` will try to read "~/.cgrc" looking for _command
guesser_ definitions; a _guesser_ is defined with the `DEFINE-GUESSER` macro as
follows:

```
(cg:define-guesser kill-kill9
    ("kill ([0-9]+)" (pid))
  (format NIL "kill -9 '~a'" pid))
```

Where:

- the first argument is the name of the guesser -- `kill-kill9`, mnemonic for
  something that transforms `kill` commands into `kill -9` ones)
- the second argument is a form defining what text the guesser is able to guess
  commands from; the first element is a regular expression (`cg`
  uses [cl-ppcre](https://edicl.github.io/cl-ppcre/) internally), while the
  second is another list, listing any group that you might have defined in the
  regular expression -- in our case we defined a single group for the Process ID
  to `kill`
- finally, one or multiple forms, the last one of which is expected to return
  a string representing the guessed command -- `kill -9 '$PID'` in our case

Currently, `cg` moves to the next input line as soon as one of the defined
guessers successfully guesses a command, but please note that I am still
dogfooding it, and this logic as well as the `DEFINE-GUESSER` API might
change in case I or you found it not so easy to work with.

Also, if you are curious to see how I am using `cg`, take a look at my
[.cgrc](https://github.com/iamFIREcracker/dotfiles/blob/master/.cgrc) file.

## Execute one of the guessed commands

So far we taught `cg` how to guess commands; but what about selecting one of
the suggestions, and run it?  Well, I did not bother implementing a Terminal UI
for this; instead, I opted to ship `cg` with an adapter for fzf:
[cg-fzf](./fzf/cg-fzf).

Hopefully, it should not take you long to implement adapters for other programs
(below you can find one for `dmenu`), but `fzf` is what I am using these days,
so that's what I will try to support going forward.

```
#!/usr/bin/env bash

cg-dmenu() {
  local commands

  IFS=$'\n' commands=($(cg | dmenu))
  for cmd in ${commands[@]}; do
    echo $cmd
    bash -c "$cmd"
  done
}
cg-dmenu
```

# Extras

## GNU Readline

Piping one command's output into another command is a lot of fun, but a lot
of typing too.

Add the following to your '.inputrc' to bind `C-G` (guess what 'g'
stands for...) to re-run the last command and pipe its output into into `cg-fzf`:

    # Pipe last command to fmcp with C-G
    "\C-g": "!-1 | cg-fzf\015"

For those unfamiliar with the syntax:

- `\C-g` is the key shortcut
- `!-1` pulls from `history` the last command
- `\015` is the return key

So say you had just run `git branch -v`; if you then pressed `C-g`, `readline`
will pass to your terminal `!-1 | cfg` which will then evaluate to (and run)
`git branch -v | cfg`!

## Tmux

If you use `tmux`, you might want to add the following to your ".tmux.conf":

    set -g @cg-key 'g'
    set -g @cg-cmd 'cg-fzf'
    run-shell ~/opt/cg/tmux/cg.tmux

That will configure `tmux` so that, when `PrefixKey + g` is pressed ('g'
again..seriously?!), `cg-fzf` is started and the content of the current pane is
piped into it.

This might come in really handy when dealing with commands that do not output
the same message the second time you run them (e.g. the first time you `git
push` a branch on GitHub, it will output a URL to create a pull request for the
branch; the second time however, it won't, so the `readline` trick I explained
above won't work in that case).

# Todo

- replace `LOAD`?!
- support multiple guesses per line, and multiple guesses per...guesser
- strip escape sequences (colors)
- enhance `DEFINE-GUESSER` to extract documentation from the definition,
  and...maybe run it?  A la python's docstring
- simplify `cg-fzf` to use `xargs` instead -- `xargs -t -I {} bash -c {}`
- reverse output before piping it into fzf (or use fzf's `--tac`) so that, when
  using tmux, suggestions from the most recent command, would appear first (i.e.
  closest to fzf prompt)

# Changelog

0.2.0 (2019-05-21)

- Don't output duplicate suggestions
- Fix a bug where the download script would fail if ./bin directory was misisng
- `chmox +x` downloaded binaries
- Stop `fzf` from sorting `cg`'s output

0.1.0 (2019-05-19)

- Add support for command line options:

```
    -h, --help               print the help text and exit
    -v, --version            print the version and exit
    -d, --debug              parse the RC file (in verbose mode) and exit
```

- Add pre-compiled binaries for each release

0.0.1 (2019-05-12)

- Load guessers from "~/.cgrc" -- use `DEFINE-GUESSER`
- One command guessed per line
- One command guessed per guesser

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
-n`'s output into it, and it would output a bunch of "git show $sha1", "git show
$sha2", "git show $sha3" entries, one per log entry;  or you pipe into it `ps
aux`'s output, and it would ask you which process to kill.

_enters `cg`.._

# Install

Differently from the other _2-letter-named_ command line utilities (i.e.
[cb](https://github.com/iamFIREcracker/cb),
[br](https://github.com/iamFIREcracker/br)) I have created in the past (pure
Bash scripts), `cg` is written in Common Lisp (stop it already!), so getting
your hands on it might not be as easy as you hoped it would, especially if
it's the first time you hear about Common Lisp.

Anyway:

- Get yourself a SBCL -- apologies, it's the only Common Lips implementation that
  I tested this with, but hopefully none of those 30 locs are incompatible with
  other Common Lisp implementations
- Get yourself Quicklisp
- Get a snapshot of this repository and `ql:quickload` it
- Run `make`

If everything run successfully, you should find `cg` under '$cgrepo/bin/'; if
not, good luck with that!

# Usage

XXX

## GNU Readline

Piping one command's output into another command is a lot of fun, but a lot
of typing too.

Add the following to your '.inputrc' to bind `C-G` (guess what 'g'
stands for...) to re-run the last command and pipe its output into into `fcg`:

    # Pipe last command to fmcp with C-G
    "\C-g": "!-1 | fcg\015"

Where:

- `\C-g` is the key shortcut
- `!-1` pulls from `history` the last command
- `\015` is the return key

So say you had just run `git branch -v`; if you then pressed `C-g`, `readline`
will pass to your terminal `!-1 | cfg` which will then evaluate to and run `git
branch -v | cfg`!

## Tmux

If you use `tmux`, you might want to add the following to your ".tmux.conf":

    set -g @fcg-key 'g'
    run-shell $cgrepo/tmux/fcg.tmux

That will configure `tmux` so that, when `PrefixKey + g` is pressed ('g'
again..seriously?!), `fcg` is started and the content of the current pane is
piped into it.

This might come in really handy when dealing with commands that do not output the same
message the second time you run them (e.g. the first time you `git push`
a branch on GitHub, it will output a URL to create a pull request for the
branch;  the second time however, it won't).

# Examples

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

XXX


# Todo

- support multiple guesses per line, and multiple guesses per `GUESSER`
- remove duplicate suggestions
- Strip escape sequences (colors)
- Simplify `fcg` to use `xargs` instead

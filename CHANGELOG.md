# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2021-10-31
### Changed
- Bump dependencies:

  + Roswell: v21.10.14.111
  + SBCL: 2.1.10 (on Linux, MacOS, and Windows)
  + Quicklisp dist: 2021-10-21
  + ASDF: 3.3.5.3

## [0.4.0] - 2020-05-13
### Fixed
- Problem where `cg` was printing anything to stdout when run from
  `cmd.exe` or `mintty.exe` on Windows.

```
# without `:deploy-console`
> cg --version
> cg --version | cat
0.3.0-r14

# with `:deploy-console`
> cg --version
0.3.0-r14
```

## [0.3.0] - 2019-07-07
### Added
- Guessers can now return multiple suggestions (i.e. they should either return
  a STRING, or a LIST (of strings))
- New section to readme, to explain how to strip colors from output before
  passing that into `cg`, and how to pipe stderr into `cg` as well.

### Changed
- Keep on processing guessers, even after a first match (this makes it possible
  for users to generate multiple suggestions for the same input line)

### Removed
- tmux plugin -- use
  [tmux-externalpipe](https://github.com/iamFIREcracker/tmux-externalpipe)
  instead

## [0.2.0] - 2019-05-21
### Changed
- `chmox +x` downloaded binaries
- Don't output duplicate suggestions
- Stop `fzf` from sorting `cg`'s output

### Fixed
- The download script would fail if ./bin directory was missing

## [0.1.0] - 2019-05-19
### Added
- Support for command line options:

```
    -h, --help               print the help text and exit
    -v, --version            print the version and exit
    -d, --debug              parse the RC file (in verbose mode) and exit
```

- Pre-compiled binaries for each release

## [0.0.1] - 2019-05-12
### Added
- Load guessers from "~/.cgrc" -- use `DEFINE-GUESSER`
- One command guessed per line
- One command guessed per guesser

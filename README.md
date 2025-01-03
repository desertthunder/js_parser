# js_parser

[![Package Version](https://img.shields.io/hexpm/v/js_parser)](https://hex.pm/packages/js_parser) [![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/js_parser/)

A lexer and parser for JavaScript, written in Gleam.

This project is inspired by the [`js-tokens`](https://github.com/lydell/js-tokens)
and [glexer](https://github.com/DanielleMaywood/glexer) packages, and aims to provide
a tool to build ECMA-262 syntax trees for gleam projects.

## Installation

```sh
gleam add js_parser
```

## Usage

`someFile.js`

```javascript
export function someFunction() {
    let someVar;
}
```

The lexer can take any string and returns a list of tokens, including whitespace
characters.

```gleam
import js_parser

pub fn main() {
  let contents = js_parser.read_file("path/to/someFile.js")
  |> js_parser.parse
  |> io.debug
}
```

Should output:

```plaintext
[
  KeywordExport, CharWhitespace(" "), KeywordFunction, CharWhitespace(" "), IdentifierName("someFunction"),CharOpenParen, CharCloseParen, CharWhitespace(" "), CharOpenBrace,
  LineTerminatorSequence("\n"), CharWhitespace("    "),
  IdentifierName("let"), CharWhitespace(" "), IdentifierName("someVar"), CharSemicolon,LineTerminatorSequence("\n"),
  CharCloseBrace, LineTerminatorSequence("\n")
]
```

```sh
gleam run -- --f samples/js/index.js
gleam test
```

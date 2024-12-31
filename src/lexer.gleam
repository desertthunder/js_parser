import gleam/io
import gleam/list
import gleam/regexp
import gleam/string

/// module Lexer contains functions that take the contents
/// of a JavaScript file and breaks it into tokens
///
/// See https://tc39.es/ecma262/#sec-ecmascript-language-lexical-grammar
/// TS https://github.com/tree-sitter/tree-sitter-javascript/blob/master/grammar.js
pub type Token {
  Type(String)
  Value(String)
}

pub type Parser {
  Line(Int)
  Column(Int)
  Tokens(List(Token))
}

pub fn tokenize_line(line) {
  io.debug("tokenzing line" <> line)
}

// Grammar module?
pub fn match_string_literal() {
  regexp.from_string("\"([^\"\\\\]|\\\\.)*\"|'([^'\\\\]|\\\\.)*'")
}

pub fn tokenize_file(contents) {
  // Naive implementation
  // we don't want to be going from line and column
  let lines = string.split(contents, "\n")
  list.each(lines, tokenize_line)
}

import gleeunit
import gleeunit/should
import js_parser/lexer

pub fn main() {
  gleeunit.main()
}

pub fn double_quote_string_literal_test() {
  let input = "\"ok\""
  input
  |> lexer.parse
  |> should.equal([lexer.StringLiteral("ok", True)])
}

pub fn single_quote_string_literal_test() {
  let input = "'ok'"
  input
  |> lexer.parse
  |> should.equal([lexer.StringLiteral("ok", True)])
}

pub fn parse_string_literal_with_escape_char_test() {
  let input = "'ok\tbro'"
  input |> lexer.parse |> should.equal([lexer.StringLiteral("ok\tbro", True)])
}

pub fn parse_identifier_name_test() {
  "var" |> lexer.parse |> should.equal([lexer.IdentifierName("var")])
}

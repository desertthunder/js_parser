import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import js_parser
import js_parser/lexer

pub fn main() {
  gleeunit.main()
}

pub fn read_file_test() {
  let contents = js_parser.read_file("samples/js/parseFileTest.js")
  case contents {
    "export function" as value <> _ ->
      should.be_true(string.starts_with(contents, value))
    _ -> should.fail()
  }
}

pub fn open_tail_template_literal_with_substition_test() {
  "`open tail template literal with a ${substition} in it"
  |> lexer.parse
  |> should.equal([
    lexer.TemplateLiteral([
      lexer.TemplateHead("open tail template literal with a "),
      lexer.IdentifierName("substition"),
      lexer.TemplateTail(" in it", False),
    ]),
  ])
}

pub fn closed_tail_template_literal_with_substition_test() {
  "`closed tail template literal with a ${substition} in it`"
  |> lexer.parse
  |> should.equal([
    lexer.TemplateLiteral([
      lexer.TemplateHead("closed tail template literal with a "),
      lexer.IdentifierName("substition"),
      lexer.TemplateTail(" in it", True),
    ]),
  ])
}

pub fn no_substition_open_template_literal_test() {
  "`open template literal without a substition"
  |> lexer.parse
  |> should.equal([
    lexer.TemplateLiteral([
      lexer.NoSubstitutionTemplate(
        "open template literal without a substition",
        False,
      ),
    ]),
  ])
}

pub fn no_substition_closed_template_literal_test() {
  "`closed template literal without a substition`"
  |> lexer.parse
  |> should.equal([
    lexer.TemplateLiteral([
      lexer.NoSubstitutionTemplate(
        "closed template literal without a substition",
        True,
      ),
    ]),
  ])
}

pub fn empty_template_literal_test() {
  "``"
  |> lexer.parse
  |> should.equal([lexer.TemplateLiteral([lexer.EmptyTemplateLiteral])])
}

pub fn parse_jsdoc_comment_test() {
  js_parser.read_file("samples/js/jsDocTest.js")
  |> lexer.parse
  |> should.equal([
    lexer.MultiLineComment(
      "/**\n * @name jsdoc test\n * @description an empty file with a comment\n */",
      True,
    ),
    lexer.LineTerminatorSequence("\n"),
  ])
}

pub fn parse_multiline_comment_test() {
  js_parser.read_file("samples/js/multilineComment.js")
  |> lexer.parse
  |> should.equal([
    lexer.MultiLineComment("/*\n * Go style multiline comment\n*/", True),
    lexer.LineTerminatorSequence("\n"),
  ])
}

pub fn parse_simple_multiline_comment_test() {
  let input = "/* this is a multiline comment on a single line */"

  input
  |> lexer.parse
  |> should.equal([lexer.MultiLineComment(input, True)])
}

pub fn parse_single_line_comment_with_cr_test() {
  js_parser.read_file("samples/js/carriageComment.js")
  |> lexer.parse
  |> should.equal([
    lexer.SingleLineComment("// This is a comment"),
    lexer.SingleLineComment(
      "// This is another comment separated by a carriage return",
    ),
    lexer.SingleLineComment(
      "// \\n\\n\\n\\r\\r\\r \\r\\n This comment contains line endings",
    ),
  ])
}

pub fn parse_single_line_comment_test() {
  let input = "// this is a comment"
  input
  |> lexer.parse
  |> should.equal([lexer.SingleLineComment(input)])
}

pub fn parse_class_with_private_identifier_test() {
  js_parser.read_file("samples/js/privateAttrTest.js")
  |> lexer.parse
  |> list.contains(lexer.PrivateIdentifier(value: "#privateInformation"))
}

pub fn parse_file_test() {
  js_parser.read_file("samples/js/parseFileTest.js")
  |> lexer.parse
  |> should.equal([
    lexer.KeywordExport,
    lexer.CharWhitespace(" "),
    lexer.KeywordFunction,
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("someFunction"),
    lexer.CharOpenParen,
    lexer.CharCloseParen,
    lexer.CharWhitespace(" "),
    lexer.CharOpenBrace,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharWhitespace("    "),
    lexer.IdentifierName("let"),
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("someVar"),
    lexer.CharSemicolon,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharCloseBrace,
    lexer.LineTerminatorSequence("\n"),
  ])
}

pub fn const_with_identifier_test() {
  let input = "const something"

  input
  |> lexer.parse
  |> should.equal([
    lexer.KeywordConst,
    lexer.CharWhitespace(value: " "),
    lexer.IdentifierName(value: "something"),
  ])
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

pub fn parse_keyword_name_test() {
  let input = "await"
  input |> lexer.parse |> should.equal([lexer.KeywordAwait])
}

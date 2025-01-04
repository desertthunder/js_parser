import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import js_parser
import simplifile as fs

fn read_file(path) -> String {
  case fs.read(from: path) {
    Ok(contents) -> contents
    Error(_) -> ""
  }
}

pub fn main() {
  gleeunit.main()
}

pub fn read_file_test() {
  let contents = read_file("samples/js/parseFileTest.js")
  case contents {
    "export function" as value <> _ ->
      should.be_true(string.starts_with(contents, value))
    _ -> should.fail()
  }
}

pub fn regexp_test() {
  read_file("samples/js/regex.js")
  |> js_parser.parse
  |> should.equal([
    js_parser.KeywordExport,
    js_parser.CharWhitespace(" "),
    js_parser.KeywordFunction,
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("regexTestCase"),
    js_parser.CharOpenParen,
    js_parser.IdentifierName("input"),
    js_parser.CharCloseParen,
    js_parser.CharWhitespace(" "),
    js_parser.CharOpenBrace,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharWhitespace("    "),
    js_parser.KeywordConst,
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("notLiteral"),
    js_parser.CharWhitespace(" "),
    js_parser.Punctuator(js_parser.CharEquals),
    js_parser.CharWhitespace(" "),
    js_parser.KeywordNew,
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("RegExp"),
    js_parser.CharOpenParen,
    js_parser.StringLiteral("ab + c", True),
    js_parser.CharCloseParen,
    js_parser.CharSemicolon,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharWhitespace("    "),
    js_parser.KeywordConst,
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("re"),
    js_parser.CharWhitespace(" "),
    js_parser.Punctuator(js_parser.CharEquals),
    js_parser.CharWhitespace(" "),
    js_parser.RegularExpressionLiteral("error+here?", True),
    js_parser.CharSemicolon,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharWhitespace("    "),
    js_parser.IdentifierName("notLiteral"),
    js_parser.CharDot,
    js_parser.IdentifierName("test"),
    js_parser.CharOpenParen,
    js_parser.StringLiteral("something", True),
    js_parser.CharCloseParen,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharWhitespace("    "),
    js_parser.IdentifierName("re"),
    js_parser.CharDot,
    js_parser.IdentifierName("test"),
    js_parser.CharOpenParen,
    js_parser.StringLiteral("something else", True),
    js_parser.CharCloseParen,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharCloseBrace,
    js_parser.LineTerminatorSequence("\n"),
  ])
}

pub fn regexp_expanded_test() {
  read_file("samples/js/regexExpanded.js")
  |> js_parser.parse
  |> should.equal([
    js_parser.KeywordExport,
    js_parser.CharWhitespace(" "),
    js_parser.KeywordFunction,
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("regexTestCase"),
    js_parser.CharOpenParen,
    js_parser.IdentifierName("input"),
    js_parser.CharCloseParen,
    js_parser.CharWhitespace(" "),
    js_parser.CharOpenBrace,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharWhitespace("    "),
    js_parser.KeywordConst,
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("re"),
    js_parser.CharWhitespace(" "),
    js_parser.Punctuator(js_parser.CharEquals),
    js_parser.CharWhitespace(" "),
    js_parser.RegularExpressionLiteral(
      "^(?:d{3}|(d{3}))([-/.])d{3}1d{4}$",
      True,
    ),
    js_parser.CharSemicolon,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharWhitespace("    "),
    js_parser.KeywordConst,
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("another"),
    js_parser.CharWhitespace(" "),
    js_parser.Punctuator(js_parser.CharEquals),
    js_parser.CharWhitespace(" "),
    js_parser.RegularExpressionLiteral("lol", True),
    js_parser.CharSemicolon,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharWhitespace("    "),
    js_parser.IdentifierName("re"),
    js_parser.CharDot,
    js_parser.IdentifierName("test"),
    js_parser.CharOpenParen,
    js_parser.IdentifierName("input"),
    js_parser.CharCloseParen,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharCloseBrace,
    js_parser.LineTerminatorSequence("\n"),
  ])
}

pub fn parse_string_variable_assignment_test() {
  "let some_var = 'value'"
  |> js_parser.parse
  |> should.equal([
    js_parser.IdentifierName("let"),
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("some_var"),
    js_parser.CharWhitespace(" "),
    js_parser.Punctuator(js_parser.CharEquals),
    js_parser.CharWhitespace(" "),
    js_parser.StringLiteral("value", True),
  ])
}

pub fn parse_arithmetic_operator_test() {
  "let x = 4 + 5;"
  |> js_parser.parse
  |> should.equal([
    js_parser.IdentifierName("let"),
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("x"),
    js_parser.CharWhitespace(" "),
    js_parser.Punctuator(js_parser.CharEquals),
    js_parser.CharWhitespace(" "),
    js_parser.NumericLiteral("4"),
    js_parser.CharWhitespace(" "),
    js_parser.Punctuator(js_parser.CharPlus),
    js_parser.CharWhitespace(" "),
    js_parser.NumericLiteral("5"),
    js_parser.CharSemicolon,
  ])
}

pub fn parse_punctuators_test() {
  "instance_of_some_class.call();"
  |> js_parser.parse
  |> should.equal([
    js_parser.IdentifierName("instance_of_some_class"),
    js_parser.CharDot,
    js_parser.IdentifierName("call"),
    js_parser.CharOpenParen,
    js_parser.CharCloseParen,
    js_parser.CharSemicolon,
  ])
}

pub fn numeric_literal_integers_test() {
  "1234"
  |> js_parser.parse
  |> should.equal([js_parser.NumericLiteral("1234")])
}

pub fn numeric_literal_integer_test() {
  "0" |> js_parser.parse |> should.equal([js_parser.NumericLiteral("0")])
}

pub fn open_tail_template_literal_with_substition_test() {
  "`open tail template literal with a ${substition} in it"
  |> js_parser.parse
  |> should.equal([
    js_parser.TemplateLiteral([
      js_parser.TemplateHead("open tail template literal with a "),
      js_parser.IdentifierName("substition"),
      js_parser.TemplateTail(" in it", False),
    ]),
  ])
}

pub fn closed_tail_template_literal_with_substition_test() {
  "`closed tail template literal with a ${substition} in it`"
  |> js_parser.parse
  |> should.equal([
    js_parser.TemplateLiteral([
      js_parser.TemplateHead("closed tail template literal with a "),
      js_parser.IdentifierName("substition"),
      js_parser.TemplateTail(" in it", True),
    ]),
  ])
}

pub fn no_substition_open_template_literal_test() {
  "`open template literal without a substition"
  |> js_parser.parse
  |> should.equal([
    js_parser.TemplateLiteral([
      js_parser.NoSubstitutionTemplate(
        "open template literal without a substition",
        False,
      ),
    ]),
  ])
}

pub fn no_substition_closed_template_literal_test() {
  "`closed template literal without a substition`"
  |> js_parser.parse
  |> should.equal([
    js_parser.TemplateLiteral([
      js_parser.NoSubstitutionTemplate(
        "closed template literal without a substition",
        True,
      ),
    ]),
  ])
}

pub fn empty_template_literal_test() {
  "``"
  |> js_parser.parse
  |> should.equal([js_parser.TemplateLiteral([js_parser.EmptyTemplateLiteral])])
}

pub fn parse_jsdoc_comment_test() {
  read_file("samples/js/jsDocTest.js")
  |> js_parser.parse
  |> should.equal([
    js_parser.MultiLineComment(
      "/**\n * @name jsdoc test\n * @description an empty file with a comment\n */",
      True,
    ),
    js_parser.LineTerminatorSequence("\n"),
  ])
}

pub fn parse_multiline_comment_test() {
  read_file("samples/js/multilineComment.js")
  |> js_parser.parse
  |> should.equal([
    js_parser.MultiLineComment("/*\n * Go style multiline comment\n*/", True),
    js_parser.LineTerminatorSequence("\n"),
  ])
}

pub fn parse_simple_multiline_comment_test() {
  let input = "/* this is a multiline comment on a single line */"

  input
  |> js_parser.parse
  |> should.equal([js_parser.MultiLineComment(input, True)])
}

pub fn parse_single_line_comment_with_cr_test() {
  read_file("samples/js/carriageComment.js")
  |> js_parser.parse
  |> should.equal([
    js_parser.SingleLineComment("// This is a comment"),
    js_parser.SingleLineComment(
      "// This is another comment separated by a carriage return",
    ),
    js_parser.SingleLineComment(
      "// \\n\\n\\n\\r\\r\\r \\r\\n This comment contains line endings",
    ),
  ])
}

pub fn parse_single_line_comment_test() {
  let input = "// this is a comment"
  input
  |> js_parser.parse
  |> should.equal([js_parser.SingleLineComment(input)])
}

pub fn parse_class_with_private_identifier_test() {
  read_file("samples/js/privateAttrTest.js")
  |> js_parser.parse
  |> list.contains(js_parser.PrivateIdentifier(value: "#privateInformation"))
}

pub fn parse_file_test() {
  read_file("samples/js/parseFileTest.js")
  |> js_parser.parse
  |> should.equal([
    js_parser.KeywordExport,
    js_parser.CharWhitespace(" "),
    js_parser.KeywordFunction,
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("someFunction"),
    js_parser.CharOpenParen,
    js_parser.CharCloseParen,
    js_parser.CharWhitespace(" "),
    js_parser.CharOpenBrace,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharWhitespace("    "),
    js_parser.IdentifierName("let"),
    js_parser.CharWhitespace(" "),
    js_parser.IdentifierName("someVar"),
    js_parser.CharSemicolon,
    js_parser.LineTerminatorSequence("\n"),
    js_parser.CharCloseBrace,
    js_parser.LineTerminatorSequence("\n"),
  ])
}

pub fn const_with_identifier_test() {
  let input = "const something"

  input
  |> js_parser.parse
  |> should.equal([
    js_parser.KeywordConst,
    js_parser.CharWhitespace(value: " "),
    js_parser.IdentifierName(value: "something"),
  ])
}

pub fn double_quote_string_literal_test() {
  let input = "\"ok\""
  input
  |> js_parser.parse
  |> should.equal([js_parser.StringLiteral("ok", True)])
}

pub fn unterminated_double_quote_string_literal_test() {
  let input = "\"ok"
  input
  |> js_parser.parse
  |> should.equal([js_parser.StringLiteral("ok", False)])
}

pub fn single_quote_string_literal_test() {
  let input = "'ok'"
  input
  |> js_parser.parse
  |> should.equal([js_parser.StringLiteral("ok", True)])
}

pub fn parse_unterminated_single_quote_string_literal_test() {
  let input = "'ok"
  input
  |> js_parser.parse
  |> should.equal([js_parser.StringLiteral("ok", False)])
}

pub fn parse_string_literal_with_escape_char_test() {
  let input = "'ok\tbro'"
  input
  |> js_parser.parse
  |> should.equal([js_parser.StringLiteral("ok\tbro", True)])
}

pub fn parse_keyword_name_test() {
  let input = "await"
  input |> js_parser.parse |> should.equal([js_parser.KeywordAwait])
}

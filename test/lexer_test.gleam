import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import js_parser/lexer
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

pub fn hashbang_comment_test() {
  "#!/usr/bin/env node"
  |> lexer.parse
  |> should.equal([lexer.HashbangComment("#!/usr/bin/env node")])
}

pub fn empty_hashbang_comment_test() {
  "#!" |> lexer.parse |> should.equal([lexer.HashbangComment("#!")])
}

pub fn numeric_literal_floats_test() {
  "1.01"
  |> lexer.parse
  |> should.equal([lexer.NumericLiteral("1.01")])
}

pub fn numeric_literal_float_test() {
  "0.55" |> lexer.parse |> should.equal([lexer.NumericLiteral("0.55")])
}

pub fn parse_no_surrounding_whitespace_division_character_test() {
  "let div = 4/4; "
  |> lexer.parse
  |> should.equal([
    lexer.IdentifierName("let"),
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("div"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharEquals),
    lexer.CharWhitespace(" "),
    lexer.NumericLiteral("4"),
    lexer.Punctuator(lexer.CharBackslash),
    lexer.NumericLiteral("4"),
    lexer.CharSemicolon,
    lexer.CharWhitespace(" "),
  ])
}

pub fn parse_backslash_character_test() {
  "let div = 4 / 2;"
  |> lexer.parse
  |> should.equal([
    lexer.IdentifierName("let"),
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("div"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharEquals),
    lexer.CharWhitespace(" "),
    lexer.NumericLiteral("4"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharBackslash),
    lexer.CharWhitespace(" "),
    lexer.NumericLiteral("2"),
    lexer.CharSemicolon,
  ])
}

pub fn regexp_test() {
  read_file("samples/js/regex.js")
  |> lexer.parse
  |> should.equal([
    lexer.KeywordExport,
    lexer.CharWhitespace(" "),
    lexer.KeywordFunction,
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("regexTestCase"),
    lexer.CharOpenParen,
    lexer.IdentifierName("input"),
    lexer.CharCloseParen,
    lexer.CharWhitespace(" "),
    lexer.CharOpenBrace,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharWhitespace("    "),
    lexer.KeywordConst,
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("notLiteral"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharEquals),
    lexer.CharWhitespace(" "),
    lexer.KeywordNew,
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("RegExp"),
    lexer.CharOpenParen,
    lexer.StringLiteral("ab + c", True),
    lexer.CharCloseParen,
    lexer.CharSemicolon,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharWhitespace("    "),
    lexer.KeywordConst,
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("re"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharEquals),
    lexer.CharWhitespace(" "),
    lexer.RegularExpressionLiteral("error+here?", True),
    lexer.CharSemicolon,
    lexer.LineTerminatorSequence("\n"),
    lexer.LineTerminatorSequence("\n"),
    lexer.CharWhitespace("    "),
    lexer.IdentifierName("notLiteral"),
    lexer.CharDot,
    lexer.IdentifierName("test"),
    lexer.CharOpenParen,
    lexer.StringLiteral("something", True),
    lexer.CharCloseParen,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharWhitespace("    "),
    lexer.IdentifierName("re"),
    lexer.CharDot,
    lexer.IdentifierName("test"),
    lexer.CharOpenParen,
    lexer.StringLiteral("something else", True),
    lexer.CharCloseParen,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharCloseBrace,
    lexer.LineTerminatorSequence("\n"),
  ])
}

pub fn regexp_expanded_test() {
  read_file("samples/js/regexExpanded.js")
  |> lexer.parse
  |> should.equal([
    lexer.KeywordExport,
    lexer.CharWhitespace(" "),
    lexer.KeywordFunction,
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("regexTestCase"),
    lexer.CharOpenParen,
    lexer.IdentifierName("input"),
    lexer.CharCloseParen,
    lexer.CharWhitespace(" "),
    lexer.CharOpenBrace,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharWhitespace("    "),
    lexer.KeywordConst,
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("re"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharEquals),
    lexer.CharWhitespace(" "),
    lexer.RegularExpressionLiteral("^(?:d{3}|(d{3}))([-/.])d{3}1d{4}$", True),
    lexer.CharSemicolon,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharWhitespace("    "),
    lexer.KeywordConst,
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("another"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharEquals),
    lexer.CharWhitespace(" "),
    lexer.RegularExpressionLiteral("lol", True),
    lexer.CharSemicolon,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharWhitespace("    "),
    lexer.IdentifierName("re"),
    lexer.CharDot,
    lexer.IdentifierName("test"),
    lexer.CharOpenParen,
    lexer.IdentifierName("input"),
    lexer.CharCloseParen,
    lexer.LineTerminatorSequence("\n"),
    lexer.CharCloseBrace,
    lexer.LineTerminatorSequence("\n"),
  ])
}

pub fn parse_string_variable_assignment_test() {
  "let some_var = 'value'"
  |> lexer.parse
  |> should.equal([
    lexer.IdentifierName("let"),
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("some_var"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharEquals),
    lexer.CharWhitespace(" "),
    lexer.StringLiteral("value", True),
  ])
}

pub fn parse_arithmetic_operator_test() {
  "let x = 4 + 5;"
  |> lexer.parse
  |> should.equal([
    lexer.IdentifierName("let"),
    lexer.CharWhitespace(" "),
    lexer.IdentifierName("x"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharEquals),
    lexer.CharWhitespace(" "),
    lexer.NumericLiteral("4"),
    lexer.CharWhitespace(" "),
    lexer.Punctuator(lexer.CharPlus),
    lexer.CharWhitespace(" "),
    lexer.NumericLiteral("5"),
    lexer.CharSemicolon,
  ])
}

pub fn parse_punctuators_test() {
  "instance_of_some_class.call();"
  |> lexer.parse
  |> should.equal([
    lexer.IdentifierName("instance_of_some_class"),
    lexer.CharDot,
    lexer.IdentifierName("call"),
    lexer.CharOpenParen,
    lexer.CharCloseParen,
    lexer.CharSemicolon,
  ])
}

pub fn numeric_literal_integers_test() {
  "1234"
  |> lexer.parse
  |> should.equal([lexer.NumericLiteral("1234")])
}

pub fn numeric_literal_integer_test() {
  "0" |> lexer.parse |> should.equal([lexer.NumericLiteral("0")])
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
  read_file("samples/js/jsDocTest.js")
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
  read_file("samples/js/multilineComment.js")
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
  read_file("samples/js/carriageComment.js")
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
  read_file("samples/js/privateAttrTest.js")
  |> lexer.parse
  |> list.contains(lexer.PrivateIdentifier(value: "#privateInformation"))
}

pub fn parse_file_test() {
  read_file("samples/js/parseFileTest.js")
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

pub fn unterminated_double_quote_string_literal_test() {
  let input = "\"ok"
  input
  |> lexer.parse
  |> should.equal([lexer.StringLiteral("ok", False)])
}

pub fn single_quote_string_literal_test() {
  let input = "'ok'"
  input
  |> lexer.parse
  |> should.equal([lexer.StringLiteral("ok", True)])
}

pub fn parse_unterminated_single_quote_string_literal_test() {
  let input = "'ok"
  input
  |> lexer.parse
  |> should.equal([lexer.StringLiteral("ok", False)])
}

pub fn parse_string_literal_with_escape_char_test() {
  let input = "'ok\tbro'"
  input
  |> lexer.parse
  |> should.equal([lexer.StringLiteral("ok\tbro", True)])
}

pub fn parse_keyword_name_test() {
  let input = "await"
  input |> lexer.parse |> should.equal([lexer.KeywordAwait])
}

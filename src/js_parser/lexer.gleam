import gleam/string
import js_parser/predicates

pub type Token {
  // String Literals
  StringLiteral(value: String, closed: Bool)
  // Template Literals
  NoSubstitutionTemplate(value: String, closed: Bool)
  TemplateHead(value: String)
  TemplateMiddle(value: String)
  TemplateTail(value: String, closed: Bool)
  // Regex
  RegularExpressionLiteral(value: String, closed: Bool)
  // Comments
  SingleLineComment(value: String)
  MultiLineComment(value: String, closed: Bool)
  HashbangComment(value: String)
  // Identifers
  IdentifierName(value: String)
  PrivateIdentifier(value: String)

  // Numbers
  NumericLiteral(value: String)
  // Special
  Punctuator(value: String)
  WhiteSpace(value: String)
  LineTerminatorSequence(value: String)

  Invalid
  EOF

  KeywordAwait
  KeywordBreak
  KeywordCase
  KeywordCatch
  KeywordClass
  KeywordConst
  KeywordContinue
  KeywordDebugger
  KeywordDefault
  KeywordDelete
  KeywordDo
  KeywordElse
  KeywordEnum
  KeywordExport
  KeywordExtends
  KeywordFalse
  KeywordFinally
  KeywordFor
  KeywordFunction
  KeywordIf
  KeywordImport
  KeywordIn
  KeywordInstanceof
  KeywordNew
  KeywordNull
  KeywordReturn
  KeywordSuper
  KeywordSwitch
  KeywordThis
  KeywordThrow
  KeywordTrue
  KeywordTry
  KeywordTypeof
  KeywordVar
  KeywordVoid
  KeywordWhile
  KeywordWith
  KeywordYield
}

pub type Character {
  CharHashbang
  CharBacktick
  CharSingleQuote
  CharDoubleQuote
  CharForwardSlash
  CharBackslash
  CharAsterisk
  CharMinus
  CharPlus
  CharDot
  CharEquals
  CharSemicolon
  CharColon
  CharComma
  CharOpenParen
  CharCloseParen
  CharOpenBrace
  CharCloseBrace
  CharOpenBracket
  CharCloseBracket
}

pub type ParserState {
  ParserState(input: String, offset: Int, tokens: List(Token))
}

pub fn new_parser_state(input: String) -> ParserState {
  ParserState(input: input, offset: 0, tokens: [])
}

pub fn parse(input: String) -> List(Token) {
  new_parser_state(input)
  |> parse_tokens
}

pub fn parse_tokens(state: ParserState) -> List(Token) {
  case parse_next_token(state) {
    #(_, EOF) -> state.tokens
    #(state, token) ->
      parse_tokens(ParserState(..state, tokens: [token, ..state.tokens]))
  }
}

// TODO: parse_template_literal
// TODO: parse_comment_or_regex
// TODO: parse_hashbang
// TODO: parse_whitespace
// TODO: parse_line_terminator
// TODO: parse_numeric_literal
// TODO: "_" | "$" -> parse_identifier
// TODO: "#" -> parse_private_identifier
// TODO: parse_punctuator
fn parse_next_token(state: ParserState) -> #(ParserState, Token) {
  case string.pop_grapheme(state.input) {
    Ok(#(grapheme, input)) -> {
      let new_state = advance_state(state, input, state.offset + 1)
      case grapheme {
        "\"" -> parse_string_literal(new_state, "", "\"")
        "'" -> parse_string_literal(new_state, "", "'")
        _ -> {
          case string.pop_grapheme(state.input) {
            Ok(_) -> parse_identifer(state)
            Error(_) -> #(state, EOF)
          }
        }
      }
    }
    Error(_) -> #(state, EOF)
  }
}

fn parse_string_literal(
  state: ParserState,
  acc: String,
  delimeter: String,
) -> #(ParserState, Token) {
  case state.input {
    "'" <> input | "\"" <> input -> {
      let new_state = advance_state(state, input, state.offset + 1)
      parse_string_literal(new_state, acc, delimeter)
    }
    "\\" as c <> input ->
      case string.pop_grapheme(input) {
        Error(_) -> {
          let new_state = advance_state(state, input, state.offset + 1)
          let value = acc <> c
          #(new_state, StringLiteral(value, closed: True))
        }
        Ok(#(grapheme, input)) -> {
          let new_state = advance_state(state, input, state.offset + 1)
          let new_acc = acc <> grapheme
          parse_string_literal(new_state, new_acc, delimeter)
        }
      }
    _ -> {
      case string.pop_grapheme(state.input) {
        Ok(#(grapheme, input)) -> {
          let new_state = advance_state(state, input, state.offset + 1)
          let new_acc = acc <> grapheme
          parse_string_literal(new_state, new_acc, delimeter)
        }
        Error(_) -> {
          let new_state = advance_state(state, state.input, state.offset + 1)
          #(new_state, StringLiteral(acc, closed: True))
        }
      }
    }
  }
}

fn advance_state(state: ParserState, input: String, offset: Int) -> ParserState {
  ParserState(..state, input:, offset:)
}

// TODO: We need to parse the starting characters of identifiers because
// $ & _ are valid in JavaScript. Right now this takes a freestanding keyword
// (i.e. not a keyword) and pulls out the word without matching against any
// keywords (type Keyword)
fn parse_identifer(state: ParserState) -> #(ParserState, Token) {
  case state.input {
    "a" as c <> input
    | "b" as c <> input
    | "c" as c <> input
    | "d" as c <> input
    | "e" as c <> input
    | "f" as c <> input
    | "g" as c <> input
    | "h" as c <> input
    | "i" as c <> input
    | "j" as c <> input
    | "k" as c <> input
    | "l" as c <> input
    | "m" as c <> input
    | "n" as c <> input
    | "o" as c <> input
    | "p" as c <> input
    | "q" as c <> input
    | "r" as c <> input
    | "s" as c <> input
    | "t" as c <> input
    | "u" as c <> input
    | "v" as c <> input
    | "w" as c <> input
    | "x" as c <> input
    | "y" as c <> input
    | "z" as c <> input -> {
      let #(new_state, name) =
        advance_state(state, input, state.offset + 1)
        |> collect_identifier(c, predicates.is_letter)

      #(new_state, IdentifierName(name))
    }
    _ -> #(state, EOF)
  }
}

fn collect_identifier(
  state: ParserState,
  acc: String,
  predicate: fn(String) -> Bool,
) -> #(ParserState, String) {
  case string.pop_grapheme(state.input) {
    Error(_) -> #(state, acc)
    Ok(#(grapheme, source)) ->
      case predicate(grapheme) {
        True ->
          advance_state(state, source, state.offset + 1)
          |> collect_identifier(acc <> grapheme, predicate)
        False -> #(state, acc)
      }
  }
}

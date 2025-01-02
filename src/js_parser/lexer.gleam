import gleam/list
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

  CharSemicolon
  CharColon
  CharComma
  CharOpenBracket
  CharCloseBracket
  CharOpenBrace
  CharCloseBrace
  CharOpenParen
  CharCloseParen
  CharWhitespace(value: String)
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
  |> list.reverse
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
//       parse_hashbang_comment
// TODO: parse_numeric_literal
// TODO:
// TODO: parse_punctuator
fn parse_next_token(state: ParserState) -> #(ParserState, Token) {
  case string.pop_grapheme(state.input) {
    Ok(#(grapheme, input)) -> {
      let new_state = advance_state(state, input, state.offset + 1)
      case grapheme {
        "\"" -> parse_string_literal(new_state, "", "\"")
        "'" -> parse_string_literal(new_state, "", "'")
        "_" as c | "$" as c -> parse_identifier(new_state, c)
        "/" -> parse_comment_or_regex(new_state)
        ":" -> #(new_state, CharColon)
        ";" -> #(new_state, CharSemicolon)
        "," -> #(new_state, CharComma)
        "{" -> #(new_state, CharOpenBrace)
        "}" -> #(new_state, CharCloseBrace)
        "[" -> #(new_state, CharOpenBracket)
        "]" -> #(new_state, CharCloseBracket)
        "(" -> #(new_state, CharOpenParen)
        ")" -> #(new_state, CharCloseParen)
        " " as c | "\t" as c -> parse_whitespace(new_state, c)
        "\n" as c | "\r" as c -> #(new_state, LineTerminatorSequence(value: c))
        _ -> {
          case string.pop_grapheme(state.input) {
            Ok(_) -> parse_identifier(state, "")
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

fn parse_identifier(state: ParserState, acc: String) -> #(ParserState, Token) {
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
        |> collect_identifier(acc <> c, predicates.is_letter)

      case name {
        "#" as c <> rest -> #(new_state, PrivateIdentifier(value: c <> rest))
        "await" -> #(new_state, KeywordAwait)
        "break" -> #(new_state, KeywordBreak)
        "case" -> #(new_state, KeywordCase)
        "catch" -> #(new_state, KeywordCatch)
        "class" -> #(new_state, KeywordClass)
        "const" -> #(new_state, KeywordConst)
        "continue" -> #(new_state, KeywordContinue)
        "debugger" -> #(new_state, KeywordDebugger)
        "default" -> #(new_state, KeywordDefault)
        "delete" -> #(new_state, KeywordDelete)
        "do" -> #(new_state, KeywordDo)
        "else" -> #(new_state, KeywordElse)
        "enum" -> #(new_state, KeywordEnum)
        "export" -> #(new_state, KeywordExport)
        "extends" -> #(new_state, KeywordExtends)
        "false" -> #(new_state, KeywordFalse)
        "finally" -> #(new_state, KeywordFinally)
        "for" -> #(new_state, KeywordFor)
        "function" -> #(new_state, KeywordFunction)
        "if" -> #(new_state, KeywordIf)
        "import" -> #(new_state, KeywordImport)
        "in" -> #(new_state, KeywordIn)
        "instanceof" -> #(new_state, KeywordInstanceof)
        "new" -> #(new_state, KeywordNew)
        "null" -> #(new_state, KeywordNull)
        "return" -> #(new_state, KeywordReturn)
        "super" -> #(new_state, KeywordSuper)
        "switch" -> #(new_state, KeywordSwitch)
        "this" -> #(new_state, KeywordThis)
        "throw" -> #(new_state, KeywordThrow)
        "true" -> #(new_state, KeywordTrue)
        "try" -> #(new_state, KeywordTry)
        "typeof" -> #(new_state, KeywordTypeof)
        "var" -> #(new_state, KeywordVar)
        "void" -> #(new_state, KeywordVoid)
        "while" -> #(new_state, KeywordWhile)
        "with" -> #(new_state, KeywordWith)
        "yield" -> #(new_state, KeywordYield)
        _ -> #(new_state, IdentifierName(name))
      }
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

fn parse_whitespace(state: ParserState, acc: String) -> #(ParserState, Token) {
  case string.pop_grapheme(state.input) {
    Error(_) -> #(state, EOF)
    Ok(#(grapheme, source)) ->
      case grapheme {
        " " | "\t" | "\n" | "\r" ->
          state
          |> advance_state(source, state.offset + 1)
          |> parse_whitespace(acc <> grapheme)
        _ -> #(state, CharWhitespace(value: acc))
      }
  }
}

fn parse_comment_or_regex(state: ParserState) -> #(ParserState, Token) {
  case string.pop_grapheme(state.input) {
    Ok(#(next_char, input)) -> {
      case next_char {
        // Single-line comment: //
        "/" as c <> _ -> {
          advance_state(state, input, state.offset + 1)
          |> advance_state(input, state.offset + 2)
          // Skip both slashes
          |> parse_single_line_comment("/" <> c)
        }

        // Multi-line comment: /*
        "*" as c <> _ -> {
          case input {
            "*" as next_c <> next_source -> {
              let #(new_state, content) =
                advance_state(state, next_source, state.offset + 2)
                |> parse_multi_line_comment("/" <> c <> next_c, fn(end) {
                  end == "*/"
                })

              #(new_state, MultiLineComment(content, True))
            }
            _ -> {
              let #(new_state, content) =
                advance_state(state, input, state.offset + 1)
                |> parse_multi_line_comment("/" <> c, fn(end) { end == "*/" })
              #(new_state, MultiLineComment(content, True))
            }
          }
        }

        // Regular expression: /pattern/flags
        _ -> #(state, EOF)
      }
    }
    Error(_) -> #(state, EOF)
  }
}

fn parse_single_line_comment(
  state: ParserState,
  result: String,
) -> #(ParserState, Token) {
  let #(final_state, content) =
    collect_while(state, result, predicates.is_end_of_input)
  #(final_state, SingleLineComment(content))
}

fn collect_while(
  state: ParserState,
  acc: String,
  predicate: fn(String) -> Bool,
) -> #(ParserState, String) {
  case string.pop_grapheme(state.input) {
    Ok(#(grapheme, input)) -> {
      case predicate(grapheme) {
        True -> {
          let new_state = advance_state(state, input, state.offset + 1)
          #(new_state, acc)
        }
        False -> {
          state
          |> advance_state(input, state.offset + 1)
          |> collect_while(acc <> grapheme, predicate)
        }
      }
    }
    Error(_) -> #(state, acc)
  }
}

fn parse_multi_line_comment(
  state: ParserState,
  acc: String,
  predicate: fn(String) -> Bool,
) -> #(ParserState, String) {
  case string.pop_grapheme(state.input) {
    Ok(#(grapheme, input)) -> {
      case input {
        "*/" as c <> source ->
          case predicate(c) {
            True -> {
              let new_state = advance_state(state, source, state.offset + 1)
              #(new_state, acc <> grapheme <> c)
            }
            False -> {
              let new_state = advance_state(state, input, state.offset + 1)
              parse_multi_line_comment(new_state, acc <> grapheme, predicate)
            }
          }
        _ -> {
          let new_state = advance_state(state, input, state.offset + 1)
          parse_multi_line_comment(new_state, acc <> grapheme, predicate)
        }
      }
    }
    Error(_) -> #(state, acc)
  }
}
// fn parse_regular_expression(state: ParserState) -> Result(#(ParserState, Token), String) {
//   // First, we need to determine if this really is a regex
//   // This requires analyzing the context, but for simplicity, we'll assume
//   // any forward slash that isn't a comment starts a regex

//   let state = advance_state(state)  // Skip initial /
//   let #(after_pattern, pattern, pattern_closed) =
//     collect_until_unescaped_helper(state, "/", "")

//   case pattern_closed {
//     False -> Ok(#(after_pattern, RegularExpressionLiteral(pattern, False)))
//     True -> {
//       // Now collect any flags (letters after the closing slash)
//       let #(final_state, flags) = collect_while(
//         after_pattern,
//         fn(char) { is_letter(char) },
//       )

//       let full_pattern = case flags {
//         "" -> pattern
//         _ -> pattern <> flags
//       }

//       Ok(#(final_state, RegularExpressionLiteral(full_pattern, True)))
//     }
//   }
// }

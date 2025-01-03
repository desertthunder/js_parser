import gleam/list
import gleam/string
import js_parser/predicates

pub type Token {
  // String Literals
  StringLiteral(value: String, closed: Bool)

  // Template Literals
  TemplateLiteral(components: List(Token))
  EmptyTemplateLiteral

  // TemplateSubstition
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

  CharDot

  Punctuator(Token)
  CharAsterisk
  CharMinus
  CharPlus
  CharEquals

  PlusAssign
  MinusAssign
  StarAssign
  DivAssign
  ModAssign
  ExpAssign
  AndAssign
  OrAssign
  XorAssign
  ShlAssign
  ShrAssign
  UshrAssign
}

pub type Character {
  CharHashbang
  CharBacktick
  CharSingleQuote
  CharDoubleQuote
  CharForwardSlash
  CharBackslash
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

pub fn append_token(state, token) -> ParserState {
  ParserState(..state, tokens: [token, ..state.tokens])
}

fn parse_next_token(state: ParserState) -> #(ParserState, Token) {
  case state.input {
    "" -> #(state, EOF)
    "\"" <> rest ->
      advance_state(state, rest, state.offset + 1)
      |> parse_string_literal("", "\"")
    "'" <> rest ->
      advance_state(state, rest, state.offset + 1)
      |> parse_string_literal("", "'")
    "`" <> rest -> {
      let #(temp_state, temp_tokens) =
        advance_state(state, rest, state.offset + 1)
        |> parse_template_literal([])
      #(temp_state, TemplateLiteral(temp_tokens |> list.reverse))
    }
    "_" as c <> rest | "$" as c <> rest ->
      advance_state(state, rest, state.offset + 1)
      |> parse_identifier(c)
    "/" <> rest ->
      advance_state(state, rest, state.offset + 1) |> parse_comment_or_regex
    ":" <> rest -> advance_and_collect(state, rest, CharColon)
    ";" <> rest -> advance_and_collect(state, rest, CharSemicolon)
    "," <> rest -> advance_and_collect(state, rest, CharComma)
    "{" <> rest -> advance_and_collect(state, rest, CharOpenBrace)
    "}" <> rest -> advance_and_collect(state, rest, CharCloseBrace)
    "[" <> rest -> advance_and_collect(state, rest, CharOpenBracket)
    "]" <> rest -> advance_and_collect(state, rest, CharCloseBracket)
    "(" <> rest -> advance_and_collect(state, rest, CharOpenParen)
    ")" <> rest -> advance_and_collect(state, rest, CharCloseParen)
    "+=" <> rest -> advance_and_collect(state, rest, Punctuator(PlusAssign))
    "-=" <> rest -> advance_and_collect(state, rest, Punctuator(MinusAssign))
    "*=" <> rest -> advance_and_collect(state, rest, Punctuator(StarAssign))
    "/=" <> rest -> advance_and_collect(state, rest, Punctuator(DivAssign))
    "%=" <> rest -> advance_and_collect(state, rest, Punctuator(ModAssign))
    "**=" <> rest -> advance_and_collect(state, rest, Punctuator(ExpAssign))
    "&=" <> rest -> advance_and_collect(state, rest, Punctuator(AndAssign))
    "|=" <> rest -> advance_and_collect(state, rest, Punctuator(OrAssign))
    "^=" <> rest -> advance_and_collect(state, rest, Punctuator(XorAssign))
    "<<=" <> rest -> advance_and_collect(state, rest, Punctuator(ShlAssign))
    ">>=" <> rest -> advance_and_collect(state, rest, Punctuator(ShrAssign))
    ">>>=" <> rest -> advance_and_collect(state, rest, Punctuator(UshrAssign))
    "=" <> rest -> advance_and_collect(state, rest, Punctuator(CharEquals))
    "*" <> rest -> advance_and_collect(state, rest, Punctuator(CharAsterisk))
    "-" <> rest -> advance_and_collect(state, rest, Punctuator(CharMinus))
    "+" <> rest -> advance_and_collect(state, rest, Punctuator(CharPlus))
    "." <> rest -> advance_and_collect(state, rest, CharDot)
    " " as c <> rest | "\t" as c <> rest ->
      advance_state(state, rest, state.offset + 1)
      |> parse_whitespace(c)
    "\n" as c <> rest | "\r" as c <> rest ->
      advance_and_collect(state, rest, LineTerminatorSequence(value: c))
    "0" as c <> rest
    | "1" as c <> rest
    | "2" as c <> rest
    | "3" as c <> rest
    | "4" as c <> rest
    | "5" as c <> rest
    | "6" as c <> rest
    | "7" as c <> rest
    | "8" as c <> rest
    | "9" as c <> rest -> {
      advance_state(state, rest, state.offset + 1) |> parse_numeric_literal(c)
    }
    _ -> {
      let assert Ok(#(grapheme, input)) = string.pop_grapheme(state.input)
      advance_state(state, input, state.offset + 1)
      |> parse_identifier(grapheme)
    }
  }
}

fn advance_and_collect(
  state: ParserState,
  input: String,
  token: Token,
) -> #(ParserState, Token) {
  let new_state = advance_state(state, input, state.offset + 1)
  #(new_state, token)
}

// TODO: Unterminated string literals
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
    | "z" as c <> input
    | "_" as c <> input
    | "$" as c <> input -> {
      let #(new_state, name) =
        advance_state(state, input, state.offset + 1)
        |> collect_identifier(acc <> c, predicates.is_identifier_char)

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

// TODO: Consider combining with collect_while
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
  case state.input {
    // Single-line comment: //
    "/" as c <> input -> {
      advance_state(state, input, state.offset + 1)
      |> advance_state(input, state.offset + 2)
      // Skip both slashes
      |> parse_single_line_comment("/" <> c)
    }

    // Multi-line comment: /*
    "*" as c <> input -> {
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

// TODO: separate lines to parse JSDoc
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

fn collect_until(
  state: ParserState,
  acc: String,
  predicate: fn(String) -> Bool,
) -> #(ParserState, String) {
  case string.pop_grapheme(state.input) {
    Ok(#(grapheme, input)) -> {
      case predicate(grapheme) {
        True -> {
          let new_state =
            advance_state(state, grapheme <> input, state.offset + 1)
          #(new_state, acc)
        }
        False -> {
          state
          |> advance_state(input, state.offset + 1)
          |> collect_until(acc <> grapheme, predicate)
        }
      }
    }
    Error(_) -> #(state, acc)
  }
}

// Template literals are wrapped around a list of Tokens
// because of the variation in their structure.
fn parse_template_literal(
  state: ParserState,
  acc: List(Token),
) -> #(ParserState, List(Token)) {
  case state.input {
    // Terminated Template Literal
    "`" <> rest -> {
      case acc {
        [] -> {
          let new_state = advance_state(state, rest, state.offset + 1)
          #(new_state, [EmptyTemplateLiteral])
        }
        _ -> {
          let new_state = advance_state(state, rest, state.offset + 1)
          #(new_state, acc)
        }
      }
    }
    // Start of substitution
    // 1. Unterminated substition
    // 2. Collect until }
    "${" <> rest -> {
      let new_state = advance_state(state, rest, state.offset + 2)
      collect_until_close(new_state, acc)
    }
    // 1. Unterminated Template Literal
    // 2. Head
    // Collect until ${
    // 3. Middle
    // Collect until ${
    // 4. Tail
    // Collect until `
    _ -> {
      let #(sub_state, value) =
        collect_until(state, "", predicates.is_end_of_segment)

      case sub_state.input {
        "${" <> rest -> {
          case acc {
            [] -> {
              let next_acc = [TemplateHead(value), ..acc]
              let #(new_state, new_acc) =
                advance_state(sub_state, rest, sub_state.offset + 1)
                |> collect_until_close(next_acc)
              parse_template_literal(new_state, new_acc)
            }
            _ -> {
              let next_acc = [TemplateMiddle(value), ..acc]
              let #(new_state, new_acc) =
                advance_state(sub_state, rest, sub_state.offset + 1)
                |> collect_until_close(next_acc)

              parse_template_literal(new_state, new_acc)
            }
          }
        }
        "`" <> rest -> {
          case acc {
            [] -> {
              let final_state = advance_state(state, rest, sub_state.offset + 1)
              #(final_state, [NoSubstitutionTemplate(value, True)])
            }
            _ -> {
              let final_state = advance_state(state, rest, sub_state.offset + 1)
              #(final_state, [TemplateTail(value, True), ..acc])
            }
          }
        }
        _ -> {
          case acc {
            [] -> #(sub_state, [NoSubstitutionTemplate(value, False)])
            _ -> {
              #(sub_state, [TemplateTail(value, False), ..acc])
            }
          }
        }
      }
    }
  }
}

// Recursively parse the substition until we reach the }
fn collect_until_close(
  state: ParserState,
  acc: List(Token),
) -> #(ParserState, List(Token)) {
  let state_copy = state
  let acc_copy = acc

  case string.split_once(state_copy.input, "}") {
    Ok(#(head, tail)) -> {
      let offset = string.length(head) + 1
      // Create a "slice" of state
      let new_acc =
        head
        |> parse
        // Merge the tokens into the original state
        |> list.fold(acc_copy, fn(initial_acc, tok) { [tok, ..initial_acc] })

      let new_state = advance_state(state_copy, tail, state.offset + offset)
      #(new_state, new_acc)
    }
    Error(_) -> {
      let offset = string.length(state_copy.input)
      let new_acc =
        state_copy
        |> parse_tokens

      let new_state = advance_state(state, "", state_copy.offset + offset)

      #(new_state, new_acc)
    }
  }
}

fn parse_numeric_literal(
  state: ParserState,
  acc: String,
) -> #(ParserState, Token) {
  case state.input {
    "0" as c <> rest
    | "1" as c <> rest
    | "2" as c <> rest
    | "3" as c <> rest
    | "4" as c <> rest
    | "5" as c <> rest
    | "6" as c <> rest
    | "7" as c <> rest
    | "8" as c <> rest
    | "9" as c <> rest ->
      advance_state(state, rest, state.offset + 1)
      |> parse_numeric_literal(acc <> c)
    c ->
      case predicates.is_digit(c) {
        True -> {
          #(state, NumericLiteral(acc <> c))
        }
        False -> {
          #(state, NumericLiteral(acc))
        }
      }
  }
}

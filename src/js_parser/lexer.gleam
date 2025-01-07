import gleam/list
import gleam/string
import js_parser/predicates

pub type Token {
  StringLiteral(value: String, closed: Bool)

  TemplateLiteral(components: List(Token))
  EmptyTemplateLiteral
  NoSubstitutionTemplate(value: String, closed: Bool)
  TemplateHead(value: String)
  TemplateMiddle(value: String)
  TemplateTail(value: String, closed: Bool)

  RegularExpressionLiteral(value: String, closed: Bool)
  SingleLineComment(value: String)
  MultiLineComment(value: String, closed: Bool)
  HashbangComment(value: String)

  IdentifierName(value: String)
  PrivateIdentifier(value: String)

  NumericLiteral(value: String)
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
  CharMod
  CharBackslash

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

  OperatorExp
  OperatorIncrement
  OperatorDecrement

  OperatorAND
  OperatorOR
  OperatorXOR
  OperatorSHL
  OperatorSHR
  OperatorUSHR
  OperatorNOT

  OperatorLogicalAND
  OperatorLogicalOR
  OperatorLogicalNOT
  OperatorNULLISH

  ComparisonEQL
  ComparisonNotEQL
  ComparisonStrictEQL
  ComparisonStrictNotEQL
  LT
  GT
  LTE
  GTE

  Arrow
  CharQuestion
  OperatorOptional
}

type LexerState {
  LexerState(input: String, offset: Int, tokens: List(Token))
}

pub fn parse(input: String) -> List(Token) {
  new_parser_state(input)
  |> parse_tokens
  |> list.reverse
}

fn new_parser_state(input: String) -> LexerState {
  LexerState(input: input, offset: 0, tokens: [])
}

fn advance_state(state: LexerState, input: String, offset: Int) -> LexerState {
  LexerState(..state, input:, offset:)
}

fn advance_and_collect(
  state: LexerState,
  input: String,
  move_by: Int,
  token: Token,
) -> #(LexerState, Token) {
  let new_state = advance_state(state, input, state.offset + move_by)
  #(new_state, token)
}

fn parse_tokens(state: LexerState) -> List(Token) {
  case parse_next_token(state) {
    #(_, EOF) -> state.tokens
    #(state, token) ->
      parse_tokens(LexerState(..state, tokens: [token, ..state.tokens]))
  }
}

fn parse_next_token(state: LexerState) -> #(LexerState, Token) {
  case state.input {
    "" -> #(state, EOF)
    "#!" <> _ -> {
      let #(new_state, contents) =
        collect_until(state, predicates.is_end_of_input)

      #(new_state, HashbangComment(contents))
    }
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
    "_" <> rest | "$" <> rest ->
      advance_state(state, rest, state.offset + 1)
      |> parse_identifier
    "/=" <> rest -> advance_and_collect(state, rest, 2, Punctuator(DivAssign))
    "/ " <> rest ->
      advance_and_collect(state, " " <> rest, 1, Punctuator(CharBackslash))
    "/" <> _ -> parse_comment_or_regex(state)
    ":" <> rest -> advance_and_collect(state, rest, 1, CharColon)
    ";" <> rest -> advance_and_collect(state, rest, 1, CharSemicolon)
    "," <> rest -> advance_and_collect(state, rest, 1, CharComma)
    "{" <> rest -> advance_and_collect(state, rest, 1, CharOpenBrace)
    "}" <> rest -> advance_and_collect(state, rest, 1, CharCloseBrace)
    "[" <> rest -> advance_and_collect(state, rest, 1, CharOpenBracket)
    "]" <> rest -> advance_and_collect(state, rest, 1, CharCloseBracket)
    "(" <> rest -> advance_and_collect(state, rest, 1, CharOpenParen)
    ")" <> rest -> advance_and_collect(state, rest, 1, CharCloseParen)
    "+=" <> rest -> advance_and_collect(state, rest, 2, Punctuator(PlusAssign))
    "-=" <> rest -> advance_and_collect(state, rest, 2, Punctuator(MinusAssign))
    "*=" <> rest -> advance_and_collect(state, rest, 2, Punctuator(StarAssign))
    "%=" <> rest -> advance_and_collect(state, rest, 2, Punctuator(ModAssign))
    "**=" <> rest -> advance_and_collect(state, rest, 3, Punctuator(ExpAssign))
    "&=" <> rest -> advance_and_collect(state, rest, 2, Punctuator(AndAssign))
    "|=" <> rest -> advance_and_collect(state, rest, 2, Punctuator(OrAssign))
    "^=" <> rest -> advance_and_collect(state, rest, 2, Punctuator(XorAssign))
    "<<=" <> rest -> advance_and_collect(state, rest, 3, Punctuator(ShlAssign))
    ">>=" <> rest -> advance_and_collect(state, rest, 3, Punctuator(ShrAssign))
    ">>>=" <> rest ->
      advance_and_collect(state, rest, 4, Punctuator(UshrAssign))
    "**" <> rest -> advance_and_collect(state, rest, 2, Punctuator(OperatorExp))
    "++" <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(OperatorIncrement))
    "--" <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(OperatorDecrement))
    "&&" <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(OperatorLogicalAND))
    "||" <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(OperatorLogicalOR))
    "??" <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(OperatorNULLISH))
    "!" <> rest ->
      advance_and_collect(state, rest, 1, Punctuator(OperatorLogicalNOT))
    "&" <> rest -> advance_and_collect(state, rest, 1, Punctuator(OperatorAND))
    "|" <> rest -> advance_and_collect(state, rest, 1, Punctuator(OperatorOR))
    "^" <> rest -> advance_and_collect(state, rest, 1, Punctuator(OperatorXOR))
    "~" <> rest -> advance_and_collect(state, rest, 1, Punctuator(OperatorNOT))
    "<<" <> rest -> advance_and_collect(state, rest, 2, Punctuator(OperatorSHL))
    ">>" <> rest -> advance_and_collect(state, rest, 2, Punctuator(OperatorSHR))
    ">>>" <> rest ->
      advance_and_collect(state, rest, 3, Punctuator(OperatorUSHR))
    "?" <> rest -> advance_and_collect(state, rest, 1, Punctuator(CharQuestion))
    "?." <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(OperatorOptional))
    "=>" <> rest -> advance_and_collect(state, rest, 2, Punctuator(Arrow))
    "==" <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(ComparisonEQL))
    "===" <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(ComparisonStrictEQL))
    "!=" <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(ComparisonNotEQL))
    "!==" <> rest ->
      advance_and_collect(state, rest, 2, Punctuator(ComparisonStrictNotEQL))
    "<" <> rest -> advance_and_collect(state, rest, 1, Punctuator(LT))
    ">" <> rest -> advance_and_collect(state, rest, 1, Punctuator(GT))
    "<=" <> rest -> advance_and_collect(state, rest, 1, Punctuator(LTE))
    ">=" <> rest -> advance_and_collect(state, rest, 1, Punctuator(GTE))
    "=" <> rest -> {
      advance_and_collect(state, rest, 1, Punctuator(CharEquals))
    }
    "*" <> rest -> advance_and_collect(state, rest, 1, Punctuator(CharAsterisk))
    "-" <> rest -> advance_and_collect(state, rest, 1, Punctuator(CharMinus))
    "+" <> rest -> {
      advance_and_collect(state, rest, 1, Punctuator(CharPlus))
    }
    "%" <> rest -> advance_and_collect(state, rest, 1, Punctuator(CharMod))
    "." <> rest -> advance_and_collect(state, rest, 1, CharDot)
    " " <> _ | "\t" <> _ -> parse_whitespace(state)
    "\n" as c <> rest | "\r" as c <> rest ->
      advance_and_collect(state, rest, 1, LineTerminatorSequence(value: c))
    "0" <> _
    | "1" <> _
    | "2" <> _
    | "3" <> _
    | "4" <> _
    | "5" <> _
    | "6" <> _
    | "7" <> _
    | "8" <> _
    | "9" <> _ -> {
      parse_numeric_literal(state, "")
    }
    _ -> {
      parse_identifier(state)
    }
  }
}

fn parse_string_literal(
  state: LexerState,
  acc: String,
  delimeter: String,
) -> #(LexerState, Token) {
  case state.input {
    "'" <> input | "\"" <> input -> {
      let new_state = advance_state(state, input, state.offset + 1)
      #(new_state, StringLiteral(acc, closed: True))
    }
    _ -> {
      let predicate = fn(ch) { ch == delimeter }
      let #(next_state, contents) = collect_until(state, predicate)
      case next_state.input {
        "'" <> _ | "\"" <> _ -> {
          let new_state =
            advance_state(next_state, next_state.input, next_state.offset + 1)

          parse_string_literal(new_state, contents, delimeter)
        }
        _ -> {
          #(next_state, StringLiteral(contents, closed: False))
        }
      }
    }
  }
}

fn parse_identifier(state: LexerState) -> #(LexerState, Token) {
  case state.input {
    "a" <> _
    | "b" <> _
    | "c" <> _
    | "d" <> _
    | "e" <> _
    | "f" <> _
    | "g" <> _
    | "h" <> _
    | "i" <> _
    | "j" <> _
    | "k" <> _
    | "l" <> _
    | "m" <> _
    | "n" <> _
    | "o" <> _
    | "p" <> _
    | "q" <> _
    | "r" <> _
    | "s" <> _
    | "t" <> _
    | "u" <> _
    | "v" <> _
    | "w" <> _
    | "x" <> _
    | "y" <> _
    | "z" <> _
    | "_" <> _
    | "$" <> _ -> {
      let #(new_state, name) =
        collect_while(state, predicates.is_identifier_char)

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
        rest -> #(new_state, IdentifierName(rest))
      }
    }
    _ -> {
      let #(new_state, name) =
        collect_while(state, predicates.is_identifier_char)
      case name {
        "" -> #(new_state, EOF)
        _ -> #(new_state, IdentifierName(name))
      }
    }
  }
}

fn parse_whitespace(state: LexerState) -> #(LexerState, Token) {
  let #(new_state, ws) = collect_while(state, predicates.is_whitespace)
  case ws {
    "" -> #(new_state, EOF)
    _ -> #(new_state, CharWhitespace(ws))
  }
}

/// Handles single and multiline comments, division operator/backslash,
/// and regular expressions. Regular expressions and division are
/// distinguished by the lack of, or presence of trailing whitespace,
/// respectively. A number as the previous token also
fn parse_comment_or_regex(state: LexerState) -> #(LexerState, Token) {
  case state.input {
    "//" <> _ -> {
      parse_single_line_comment(state)
    }
    "/*" as c <> rest -> {
      advance_state(state, rest, state.offset + 2)
      |> parse_multi_line_comment(c)
    }
    "/" <> input -> {
      case state.tokens {
        [NumericLiteral(_), ..] -> {
          advance_and_collect(state, input, 1, Punctuator(CharBackslash))
        }
        _ -> {
          advance_state(state, input, state.offset + 1)
          |> parse_regular_expression("")
        }
      }
    }
    "/" -> {
      #(state, CharBackslash)
    }
    _ -> #(state, EOF)
  }
}

/// Collects a single line comment based on the end of input predicate
fn parse_single_line_comment(state: LexerState) -> #(LexerState, Token) {
  let #(new_state, content) = collect_until(state, predicates.is_end_of_input)
  case new_state.input {
    "\n" <> input | "\r" <> input | "\r\n" <> input -> {
      advance_and_collect(new_state, input, 1, SingleLineComment(content))
    }
    _ -> {
      #(new_state, SingleLineComment(content))
    }
  }
}

fn parse_multi_line_comment(
  state: LexerState,
  acc: String,
) -> #(LexerState, Token) {
  let star_predicate = fn(end) { end == "*" }
  let backslash_predicate = fn(end) { end == "/" }

  let #(star_state, star_contents) = collect_until(state, star_predicate)
  let #(slash_state, slash_contents) =
    collect_until(star_state, backslash_predicate)

  case slash_state.input {
    "/" <> rest -> {
      let new_state = advance_state(slash_state, rest, slash_state.offset + 1)
      #(
        new_state,
        MultiLineComment(acc <> star_contents <> slash_contents <> "/", True),
      )
    }
    _ -> {
      #(
        slash_state,
        MultiLineComment(acc <> star_contents <> slash_contents, False),
      )
    }
  }
}

/// Collects a template literal and wraps the collected tokens in a
/// TemplateLiteral token.
///
/// Note that that template literals are wrapped around a list of Tokens
/// because of the variation in their structure (head, middle, tail) and
/// because substitions can be valid JavaScript expressions.
fn parse_template_literal(
  state: LexerState,
  acc: List(Token),
) -> #(LexerState, List(Token)) {
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
        collect_until(state, predicates.is_end_of_segment)

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

fn parse_numeric_literal(state: LexerState, acc: String) -> #(LexerState, Token) {
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
    | "9" as c <> rest -> {
      let next_state = advance_state(state, rest, state.offset + 1)
      case next_state.input {
        "." as d <> input -> {
          advance_state(next_state, input, next_state.offset + 1)
          |> parse_numeric_literal(acc <> c <> d)
        }
        _ -> {
          next_state
          |> parse_numeric_literal(acc <> c)
        }
      }
    }
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

fn parse_regular_expression(
  state: LexerState,
  acc: String,
) -> #(LexerState, Token) {
  case state.input {
    "/" -> {
      #(state, RegularExpressionLiteral(acc, True))
    }
    _ -> {
      let #(next_state, next_acc) = collect_until(state, fn(ch) { ch == "\\" })

      case next_state.input {
        "\\" <> input -> {
          advance_state(next_state, input, state.offset + 1)
          |> parse_regular_expression(acc <> next_acc)
        }
        _ -> {
          let #(new_state, new_acc) = collect_until(state, fn(ch) { ch == "/" })

          case new_state.input {
            "/" <> input -> {
              advance_and_collect(
                new_state,
                input,
                1,
                RegularExpressionLiteral(acc <> new_acc, True),
              )
            }
            _ -> #(new_state, RegularExpressionLiteral(new_acc, False))
          }
        }
      }
    }
  }
}

/// Collects a sequence of characters for a token with a value field
/// until it reaches the end of the file, usually signifying an
/// unterminated sequence, based on the predicate function provided by
/// the caller.
fn collect_while(
  state: LexerState,
  predicate: fn(String) -> Bool,
) -> #(LexerState, String) {
  let input = string.to_graphemes(state.input)
  let acc = input |> list.take_while(predicate)
  let #(_, new_input) = list.split(input, list.length(acc))

  #(
    advance_state(
      state,
      merge_graphemes_into(new_input, ""),
      state.offset + list.length(acc),
    ),
    merge_graphemes_into(acc, ""),
  )
}

/// Similar to collect_while but instead includes the character
/// used by the predicate function (the end of the sequence usually)
/// so that the template literal collector is aware of which portion
/// of the template the parser is working through (i.e. head, middle, tail)
///
fn collect_until(
  state: LexerState,
  predicate: fn(String) -> Bool,
) -> #(LexerState, String) {
  let input = string.to_graphemes(state.input)
  let acc =
    input
    |> list.take_while(fn(ch) { !predicate(ch) })
  let #(_, new_input) = list.split(input, list.length(acc))

  #(
    advance_state(
      state,
      merge_graphemes_into(new_input, ""),
      state.offset + list.length(acc),
    ),
    merge_graphemes_into(acc, ""),
  )
}

/// A helper function used to collect the tokens within a template literal
/// substition. It recursively parses the substition until reaching the }
/// character
fn collect_until_close(
  state: LexerState,
  acc: List(Token),
) -> #(LexerState, List(Token)) {
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

fn merge_graphemes_into(input, acc) {
  list.fold(input, acc, fn(a, b) { a <> b })
}

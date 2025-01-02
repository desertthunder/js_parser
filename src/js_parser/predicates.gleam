import gleam/list
import gleam/string

pub fn is_letter(char: String) -> Bool {
  string.to_utf_codepoints(char)
  |> list.map(fn(c) { string.utf_codepoint_to_int(c) })
  |> list.any(fn(c) { { c >= 65 && c <= 90 } || { c >= 97 && c <= 122 } })
}

pub fn is_identifier_start(char: String) -> Bool {
  char == "_" || char == "$" || is_letter(char)
}

pub fn is_punctuator_start(char: String) -> Bool {
  let punctuators = [
    "+", "-", "*", "/", "%", "=", "!", "<", ">", "&", "|", "^", "~", "?", ":",
    ";", ",", ".", "(", ")", "[", "]", "{", "}",
  ]
  list.contains(punctuators, char)
}

pub fn is_end_of_input(char: String) -> Bool {
  let line_terminators = ["\n", "\r", "\r\n"]

  list.contains(line_terminators, char)
}

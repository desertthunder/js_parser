import gleam/list
import gleam/string

pub fn is_letter(char: String) -> Bool {
  string.to_utf_codepoints(char)
  |> list.map(fn(c) { string.utf_codepoint_to_int(c) })
  |> list.any(fn(c) { { c >= 65 && c <= 90 } || { c >= 97 && c <= 122 } })
}

pub fn is_identifier_char(char: String) -> Bool {
  char == "_" || char == "$" || is_letter(char) || is_number(char)
}

fn is_number(char) {
  ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] |> list.contains(char)
}

pub fn is_punctuator_start(char: String) -> Bool {
  [
    "+", "-", "*", "/", "%", "=", "!", "<", ">", "&", "|", "^", "~", "?", ":",
    ";", ",", ".", "(", ")", "[", "]", "{", "}",
  ]
  |> list.contains(char)
}

pub fn is_end_of_input(char: String) -> Bool {
  ["\n", "\r", "\r\n"]
  |> list.contains(char)
}

// End of a template literal segment
pub fn is_end_of_segment(char: String) -> Bool {
  char == "$" || char == "`"
}

pub fn is_digit(char: String) -> Bool {
  ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  |> list.contains(char)
}

import argv
import simplifile as fs

/// Reads a file and returns either the contents of the file or an empty string
/// if it's not found
pub fn read_file(path) -> String {
  case fs.read(from: path) {
    Ok(contents) -> contents
    Error(_) -> ""
  }
}

/// A cli with a flag, f, that takes a path to a file and returns its string
/// contents.
pub fn main() {
  case argv.load().arguments {
    ["-f", rest] | ["--f", rest] -> read_file(rest)
    _ -> "Empty File"
  }
}

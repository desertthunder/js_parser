import argv
import gleam/io
import simplifile as fs

fn read_file(path) -> Nil {
  case fs.read(from: path) {
    Ok(c) -> io.print(c)
    Error(_) -> io.print_error("unable to read file " <> path)
  }
  Nil
}

pub fn main() {
  let args = argv.load().arguments
  case args {
    ["--f", rest] -> read_file(rest)
    _ -> io.println("no match")
  }
}

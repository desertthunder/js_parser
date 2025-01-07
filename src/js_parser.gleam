pub type ParserState {
  ParserState(program: Program, position: Position, src: String)
}

pub type Program {
  Program(source_type: SourceType, nodes: List(Node))
}

pub type SourceType {
  Script
  Module
}

pub type Position {
  Position(line: Int, column: Int)
}

pub type Node {
  Node(node_type: NodeType, start: Position, end: Position, nodes: List(Node))
}

pub type NodeType {
  Expression
  Statement
  Literal(value: String)
  RegExLiteral(pattern: String, flags: String)
  Identifier(value: String, anonymous: Bool)
}

pub fn init_state(src, source_type) {
  ParserState(Program(source_type, []), Position(0, 0), src)
}

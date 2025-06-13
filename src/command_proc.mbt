///|
let usage =
  #|  usage: sudoku <command> [options] 
  #|  commands:
  #|    solve: Solve the sudoku puzzle in the file
  #|      sudoku solve <file>
  #|    fmt: Format the sudoku puzzle in the file
  #|      sudoku fmt <file>
  #|    export: Export the sudoku puzzle in the file
  #|      sudoku export <file> <solve|fmt> <output>
  #|    help: Usage information

///|
let notice =
  #|  Use "sudoku help" to see the usage information.

///|
let commands : Map[String, Int] = {
  "help": 1,
  "solve": 2,
  "fmt": 2,
  "export": 3,
}

///|
fn check_command(argv : Array[String]) -> Unit raise ArgError {
  let len = argv.length() - 1
  let command = argv[1]
  if commands.contains(command) {
    if len != commands.get(command).unwrap() {
      raise ArgError(
        ErrorData::make(
          "ArgError",
          "Invalid amount of arguments for command '\{command}'",
          position=1,
        ),
      )
    }
  } else {
    raise ArgError(
      ErrorData::make("ArgError", "Unknown command '\{command}'", position=1),
    )
  }
}

///|
fn check_file(pos : Int, argv : Array[String]) -> Bool raise Error {
  try is_file(argv[pos]) catch {
    @fs.IOError(msg) =>
      raise IOError(
        ErrorData::make("IOError", "\{msg}: \{argv[pos]}", position=pos),
      )
    _ => abort("An unknown error occurred")
  } else {
    res => return res
  }
  true
}

///|
fn read_raw(pos : Int, argv : Array[String]) -> String raise Error {
  try read_file_to_string(argv[pos]) catch {
    @fs.IOError(msg) =>
      raise IOError(
        ErrorData::make("IOError", "\{msg}: \{argv[pos]}", position=pos),
      )
    _ => abort("An unknown error occurred")
  } else {
    res => return res
  }
}

///|
fn solve_to_string(argv : Array[String]) -> String raise Error {
  let pos = 2
  guard check_file(pos, argv) else {
    raise IOError(
      ErrorData::make(
        "IOError",
        "Not a file or file doesn't exist: \{argv[pos]}",
        position=pos,
      ),
    )
  }
  fn solve(raw : String) -> String {
    matrix_to_string(mask_algorithm(raw_to_matrix(raw)))
  }

  let raw = read_raw(pos, argv)
  if raw.contains("\n") {
    let sudoku_arr = data_slice(raw)
    sudoku_arr.map(solve).join("\n")
  } else {
    solve(raw)
  }
}

///|
fn solve_handler(argv : Array[String]) -> Unit raise Error {
  try solve_to_string(argv) catch {
    IOError(msg) => raise IOError(msg)
    DataError(msg) => raise DataError(msg)
    _ => abort("An unknown error occurred")
  } else {
    res => println(res)
  }
}

///|
fn fmt_to_string(argv : Array[String]) -> String raise Error {
  let pos = 2
  guard check_file(pos, argv) else {
    raise IOError(
      ErrorData::make(
        "IOError",
        "Not a file or file doesn't exist: \{argv[pos]}",
        position=pos,
      ),
    )
  }
  fn fmt(raw : String) -> String {
    fn get_num(c : Char) -> Char {
      if c >= '1' && c <= '9' {
        return c
      } else {
        return ' '
      }
    }

    let char_arr = raw.to_array().map(get_num)
    let matrix = Matrix::from_array(9, 9, char_arr)
    let str = []
    let space = " "
    for i in 0..<9 {
      str.push(" \{matrix.row_to_array(i).map(Char::to_string).join(space)}\n")
    }
    str.join("")
  }

  let raw = read_raw(pos, argv)
  if raw.contains("\n") {
    let sudoku_arr = data_slice(raw)
    sudoku_arr.map(fmt).join("\n")
  } else {
    fmt(raw)
  }
}

///|
fn fmt_handler(argv : Array[String]) -> Unit raise Error {
  try fmt_to_string(argv) catch {
    IOError(msg) => raise IOError(msg)
    DataError(msg) => raise DataError(msg)
    _ => abort("An unknown error occurred")
  } else {
    res => println(res)
  }
}

///|
fn export_handler(argv : Array[String]) -> Unit raise Error {
  ...
}

///|
fn command_handler(argv : Array[String]) -> Unit raise Error {
  check_command(argv)
  let command = argv[1]
  if command == "help" {
    println(usage)
  } else if command == "solve" {
    solve_handler(argv)
  } else if command == "fmt" {
    fmt_handler(argv)
  } else if command == "export" {
    export_handler(argv)
  }
}

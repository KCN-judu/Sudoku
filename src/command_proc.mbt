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
  #|Use "sudoku help" to see the usage information.

///|
let commands : Map[String, Int32] = {
  "help": 1,
  "solve": 2,
  "fmt": 2,
  "export": 4,
}

///|
fn err_wrapper(e_type : String, e_msg : String, e_pos : Int32) -> ErrorData {
  ErrorData::make(err_type=Some(e_type), e_msg, err_pos=e_pos)
}

///|
let arg_err_wrapper : (String, Int32) -> ErrorData = (msg, pos) => {
  err_wrapper("ArgError", msg, pos)
}

///|
let io_err_wrapper : (String, Int32) -> ErrorData = (msg, pos) => {
  err_wrapper("IOError", msg, pos)
}

///|
let data_err_wrapper : (String, Int32) -> ErrorData = (msg, pos) => {
  err_wrapper("DataError", msg, pos)
}

///|
fn check_command(argv : Array[String]) -> Unit raise ArgError {
  let len = argv.length() - 1
  if len < 2 {
    raise ArgError(arg_err_wrapper("Invalid amount of arguments", 1))
  }
  let command = argv[1]
  if commands.contains(command) {
    if len != commands.get(command).unwrap() {
      raise ArgError(
        arg_err_wrapper(
          "Invalid amount of arguments for command '\{command}'",
          1,
        ),
      )
    }
  } else {
    raise ArgError(arg_err_wrapper("Unknown command '\{command}'", 1))
  }
}

///|
fn check_file(pos : Int32, argv : Array[String]) -> Bool raise Error {
  try is_file(argv[pos]) catch {
    @fs.IOError(msg) =>
      raise IOError(io_err_wrapper("\{msg}: \{argv[pos]}", pos))
  } noraise {
    res => return res
  }
  true
}

///|
fn read_raw(pos : Int32, argv : Array[String]) -> String raise Error {
  try read_file_to_string(argv[pos]) catch {
    @fs.IOError(msg) =>
      raise IOError(io_err_wrapper("\{msg}: \{argv[pos]}", pos))
  } noraise {
    res => return res
  }
}

///|
fn solve_to_string(
  argv : Array[String],
  pos~ : Int32 = 2,
) -> String raise Error {
  guard check_file(pos, argv) else {
    raise IOError(io_err_wrapper("File not found: \{argv[pos]}", pos))
  }
  fn solve(raw : String) -> String {
    matrix_to_string(candidate_algorithm(raw_to_matrix(raw)))
  }

  let raw = read_raw(pos, argv)
  if raw.contains("\n") {
    let sudoku_arr = data_slice(raw)
    sudoku_arr.each(x => is_sudoku_file(x, pos~))
    sudoku_arr.map(solve).join("\n")
  } else {
    is_sudoku_file(raw, pos~)
    solve(raw)
  }
}

///|
fn solve_handler(argv : Array[String]) -> Unit raise Error {
  try solve_to_string(argv) catch {
    IOError(msg) => raise IOError(msg)
    DataError(msg) => raise DataError(msg)
    _ => abort("An unknown error occurred")
  } noraise {
    res => println(res)
  }
}

///|
fn fmt_to_string(argv : Array[String], pos~ : Int32 = 2) -> String raise Error {
  guard check_file(pos, argv) else {
    raise IOError(io_err_wrapper("File not found: \{argv[pos]}", pos))
  }
  fn fmt(raw : String) -> String {
    fn get_num(c : Char) -> Char {
      if c is ('1'..<='9') {
        c
      } else {
        ' '
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
    sudoku_arr.each(x => is_sudoku_file(x, pos~))
    sudoku_arr.map(fmt).join("\n")
  } else {
    is_sudoku_file(raw)
    fmt(raw)
  }
}

///|
fn fmt_handler(argv : Array[String]) -> Unit raise Error {
  try fmt_to_string(argv) catch {
    IOError(msg) => raise IOError(msg)
    DataError(msg) => raise DataError(msg)
    _ => abort("An unknown error occurred.")
  } noraise {
    res => println(res)
  }
}

///|
fn export_handler(argv : Array[String]) -> Unit raise Error {
  // `sudoku export <file> <solve|fmt> <output>`: argv[2] is read, argv[4] is
  // written (#12). The content is computed first, so a bad mode or input
  // writes nothing.
  let content = match argv[3] {
    "solve" => solve_to_string(argv, pos=2)
    "fmt" => fmt_to_string(argv, pos=2)
    mode =>
      raise ArgError(arg_err_wrapper("Invalid export command: '\{mode}'", 3))
  }
  let path = argv[4]
  if path.is_blank() {
    raise IOError(io_err_wrapper("File path cannot be empty", 4))
  }
  if path == argv[2] {
    raise IOError(
      io_err_wrapper("The output file must differ from the input file", 4),
    )
  }
  if path.rev_find("/") is Some(x) {
    if x == path.length() - 1 {
      raise IOError(io_err_wrapper("Invalid file end with '/'.", 4))
    }
    let dir = path.unsafe_substring(start=0, end=x)
    try is_dir(dir) catch {
      @fs.IOError(_) =>
        create_dir(dir) catch {
          @fs.IOError(msg) => raise IOError(io_err_wrapper("\{msg}", 4))
        }
    } noraise {
      b => ignore(b)
    }
  }
  write_string_to_file(path, content) catch {
    @fs.IOError(msg) => raise IOError(io_err_wrapper("\{msg}", 4))
  }
}

///|
fn command_handler(argv : Array[String]) -> Unit raise Error {
  let command = argv[1]
  if command == "help" {
    println(usage)
  } else {
    check_command(argv)
    if command == "solve" {
      solve_handler(argv)
    } else if command == "fmt" {
      fmt_handler(argv)
    } else if command == "export" {
      export_handler(argv)
    }
  }
}

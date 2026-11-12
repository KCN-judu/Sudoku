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
let notice = "run `sudoku help` to see the usage"

///|
let commands : Map[String, Array[String]] = {
  "help": [],
  "solve": ["<file>"],
  "fmt": ["<file>"],
  "export": ["<file>", "<solve|fmt>", "<output>"],
}

///|
fn err_wrapper(e_type : String, e_msg : String, e_pos : Int32) -> Report {
  Report::new(@em.Severity::Error, e_msg)
  .with_code(e_type)
  .with_mark(Mark::primary(Span::new(e_pos, e_pos + 1)))
}

///|
let arg_err_wrapper : (String, Int32) -> Report = (msg, pos) => {
  err_wrapper("ArgError", msg, pos)
}

///|
let io_err_wrapper : (String, Int32) -> Report = (msg, pos) => {
  err_wrapper("IOError", msg, pos)
}

///|
let data_err_wrapper : (String, Int32) -> Report = (msg, pos) => {
  err_wrapper("DataError", msg, pos)
}

///|
fn check_command(argv : Array[String]) -> Unit raise ArgError {
  let command = argv[1]
  guard commands.get(command) is Some(params) else {
    raise ArgError(
      arg_err_wrapper("Unknown command '\{command}'", 1).with_note(
        "commands: solve, fmt, export, help",
      ),
    )
  }
  let given = argv.length() - 2
  if given == params.length() {
    return
  }
  // Every missing or surplus argument is marked in one report (#11).
  let mut report = Report::new(
      @em.Severity::Error,
      if given < params.length() {
        "Missing arguments for '\{command}'"
      } else {
        "Too many arguments for '\{command}'"
      },
    )
    .with_code("ArgError")
    .with_mark(Mark::secondary(Span::new(1, 2)))
  if given < params.length() {
    let missing = []
    for k in given..<params.length() {
      missing.push(params[k])
    }
    report = report.with_mark(
      Mark::primary(
        Span::point(argv.length()),
        message="expected " + missing.join(" "),
      ),
    )
  } else {
    let first = 2 + params.length()
    report = report.with_mark(
      Mark::primary(Span::new(first, argv.length()), message="unexpected"),
    )
  }
  raise ArgError(report)
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
  // written (#12). All argument problems are reported together (#11), and the
  // content is computed before anything is written.
  let input = argv[2]
  let mode = argv[3]
  let output = argv[4]
  let problems : Array[Mark] = []
  let input_exists = is_file(input) catch { _ => false }
  if !input_exists {
    problems.push(Mark::primary(Span::new(2, 3), message="no such file"))
  }
  if mode != "solve" && mode != "fmt" {
    problems.push(
      Mark::primary(Span::new(3, 4), message="expected solve or fmt"),
    )
  }
  if output.is_blank() {
    problems.push(Mark::primary(Span::new(4, 5), message="empty path"))
  } else if output == input {
    problems.push(
      Mark::primary(Span::new(4, 5), message="same file as the input"),
    )
  } else if output.has_suffix("/") {
    problems.push(Mark::primary(Span::new(4, 5), message="not a file name"))
  }
  if !problems.is_empty() {
    raise ArgError(
      problems.fold(
        init=Report::new(@em.Severity::Error, "Invalid export arguments").with_code(
          "ArgError",
        ),
        (r, m) => r.with_mark(m),
      ),
    )
  }
  let content = if mode == "solve" {
    solve_to_string(argv, pos=2)
  } else {
    fmt_to_string(argv, pos=2)
  }
  let path = output
  if path.rev_find("/") is Some(x) {
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
  guard argv.length() >= 2 else {
    raise ArgError(arg_err_wrapper("Missing command", 1))
  }
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

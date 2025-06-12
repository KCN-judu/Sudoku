///|
let usage =
  #|  usage: sudoku <command> <file_input>
  #|  commands:
  #|    solve: Solve the sudoku puzzle in the file
  #|    fmt: Format the sudoku puzzle in the file
  #|    help: Usage information

///|
suberror ArgError String

///|
fn check_arg(argv : Array[String]) -> Bool raise Error {
  if argv.length() == 2 && argv[1] == "help" {
    println(usage)
    return false
  }
  if argv.length() != 3 {
    raise ArgError("Invalid number of arguments.\n\{usage}")
  }
  let (command, file) = (argv[1], argv[2])
  if command != "solve" && command != "fmt" {
    raise ArgError("Invalid command. Use 'solve' or 'fmt'.\n\{usage}")
  }
  if is_file(file) == false {
    raise @fs.IOError("this is not a file: \{file}")
  }
  return true
}

///|
suberror DataError String

///|
fn is_valid_sudoku_file(data : String) -> Unit raise DataError {
  if data.length() != 81 {
    raise DataError("This is not a valid Sudoku file.")
  }
}

///|
fn solver(data : String) -> String {
  let sudoku = raw_to_matrix(data)
  matrix_to_string(mask_algorithm(sudoku))
}

///|
fn formatter(data : String) -> String {
  fn get_num(c : Char) -> Char {
    if c >= '1' && c <= '9' {
      return c
    } else {
      return ' '
    }
  }

  let char_arr = data.to_array().map(get_num)
  let matrix = Matrix::from_array(9, 9, char_arr)
  //let matrix = Matrix::new(9, 9, '1')
  let mut str = ""
  for i in 0..<9 {
    str += " " + matrix.row_to_array(i).map(Char::to_string).join(" ") + "\n"
  }
  str
}

///|
fn print_error_msg(err_type : String, reason : String) -> Unit {
  println("Error[\{err_type}]: \{reason}")
}

///|
fn main {
  let argv = get_cli_args()
  try check_arg(argv) catch {
    ArgError(msg) => print_error_msg("arg_error", msg)
    @fs.IOError(msg) => print_error_msg("io_error", msg)
    _ => print_error_msg("unknown_error", "An unexpected error occurred.")
  } else {
    b =>
      if b == false {
        return
      } else {
        try read_file_to_string(argv[2]) catch {
          @fs.IOError(msg) => print_error_msg("io_error", msg)
          _ =>
            print_error_msg(
              "unknown_error", "An unexpected error occurred while reading the file.",
            )
        } else {
          data => {
            is_valid_sudoku_file(data) catch {
              DataError(msg) => print_error_msg("data_error", msg)
            }
            if argv[1] == "solve" {
              println("\{solver(data)}")
            } else if argv[1] == "fmt" {
              println("\{formatter(data)}")
            }
          }
        }
      }
  }
}

///|
/// Rendered error reports (#11): every bad argument is marked in one report.
fn report_of(argv : Array[String]) -> String {
  command_handler(argv) catch {
    ArgError(r) => return err_msg_with_note(r, argv)
    IOError(r) => return err_msg_with_note(r, argv)
    DataError(r) => return err_msg_with_note(r, argv)
    _ => return "unexpected error"
  }
  "no error"
}

///|
test "unknown command" {
  inspect(report_of(["sudoku", "sovle", "a.txt"]), content=(
    #|sudoku sovle a.txt
    #|       ^^^^^
    #|error[ArgError]: Unknown command 'sovle'
    #|note: commands: solve, fmt, export, help
    #|note: run `sudoku help` to see the usage
  ))
}

///|
test "missing argument is a point after the last argument" {
  inspect(report_of(["sudoku", "solve"]), content=(
    #|sudoku solve
    #|       -----^ expected <file>
    #|error[ArgError]: Missing arguments for 'solve'
    #|note: run `sudoku help` to see the usage
  ))
}

///|
test "surplus arguments are marked together" {
  inspect(report_of(["sudoku", "solve", "a", "b", "c"]), content=(
    #|sudoku solve a b c
    #|       -----   ^^^ unexpected
    #|error[ArgError]: Too many arguments for 'solve'
    #|note: run `sudoku help` to see the usage
  ))
}

///|
test "export reports every problem at once" {
  inspect(
    report_of(["sudoku", "export", "missing_input.txt", "slove", "out/"]),
    content=(
      #|sudoku export missing_input.txt slove out/
      #|              ^^^^^^^^^^^^^^^^^ ^^^^^ ^^^^ not a file name
      #|              no such file      expected solve or fmt
      #|error[ArgError]: Invalid export arguments
      #|note: run `sudoku help` to see the usage
    ),
  )
}

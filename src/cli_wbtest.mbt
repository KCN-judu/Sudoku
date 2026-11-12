///|
test "a missing command is an error, not a panic (#13)" {
  let failed = try {
    command_handler(["sudoku"])
    false
  } catch {
    ArgError(_) => true
    _ => false
  }
  assert_true(failed)
}

///|
test "input lines: trailing newline, CRLF and blank lines are ignored (#13)" {
  assert_eq(data_slice("a\n"), ["a"])
  assert_eq(data_slice("a\r\nb\r\n"), ["a", "b"])
  assert_eq(data_slice("a\n\n  \nb"), ["a", "b"])
}

///|
test "a file of one puzzle with a trailing newline is solved (#13)" {
  let p = "530070000600195000098000060800060003400803001700020006060000280000419005000080079"
  let lines = data_slice(p + "\n")
  assert_eq(lines.length(), 1)
  is_sudoku_file(lines[0])
}

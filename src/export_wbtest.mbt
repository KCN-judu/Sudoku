///|
/// #12: `export` reads argv[2] and writes argv[4], as `help` documents, and
/// never touches the input. Native only: it writes real files.
let puzzle = "530070000600195000098000060800060003400803001700020006060000280000419005000080079"

///|
fn scratch_dir() -> String {
  let dir = "_build/export_wbtest"
  ignore(is_dir(dir)) catch {
    _ => create_dir(dir) catch { _ => () }
  }
  dir
}

///|
test "export solve writes the output and keeps the input" {
  let dir = scratch_dir()
  let input = dir + "/in.txt"
  let output = dir + "/out.txt"
  write_string_to_file(input, puzzle)
  write_string_to_file(output, "old content")
  export_handler(["sudoku", "export", input, "solve", output])
  assert_eq(read_file_to_string(input), puzzle)
  assert_eq(read_file_to_string(output), solve_to_string([input], pos=0))
}

///|
test "export with an unknown mode writes nothing" {
  let dir = scratch_dir()
  let input = dir + "/in2.txt"
  let output = dir + "/out2.txt"
  write_string_to_file(input, puzzle)
  write_string_to_file(output, "untouched")
  let failed = try {
    export_handler(["sudoku", "export", input, "sovle", output])
    false
  } catch {
    _ => true
  }
  assert_true(failed)
  assert_eq(read_file_to_string(output), "untouched")
}

///|
test "export refuses to write over its input" {
  let dir = scratch_dir()
  let input = dir + "/in3.txt"
  write_string_to_file(input, puzzle)
  let failed = try {
    export_handler(["sudoku", "export", input, "solve", input])
    false
  } catch {
    _ => true
  }
  assert_true(failed)
  assert_eq(read_file_to_string(input), puzzle)
}

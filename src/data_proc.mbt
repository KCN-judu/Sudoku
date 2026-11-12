///|
fn is_sudoku_file(data : String, pos~ : Int32 = 2) -> Unit raise DataError {
  if data.length() != 81 {
    raise DataError(
      data_err_wrapper("Invalid Sudoku file length: \{data.length()}", pos),
    )
  }
}

///|
fn data_slice(raw : String) -> Array[String] {
  // One puzzle per line; a trailing `\r` (CRLF files) and empty lines, such
  // as the one after the final newline, are ignored (#13).
  let out = []
  for v in raw.split("\n") {
    let line = v.to_owned()
    let n = line.length()
    let line = if n > 0 && line[n - 1] == '\r'.to_int().to_uint16() {
      line.unsafe_substring(start=0, end=n - 1)
    } else {
      line
    }
    if !line.is_blank() {
      out.push(line)
    }
  }
  out
}

///|
fn raw_to_matrix(raw : String) -> Matrix[Int32] {
  Matrix::from_array(
    9,
    9,
    raw
    .to_array()
    .map(c => {
      match c {
        '1'..<='9' => c.to_int() - '1'.to_int() + 1
        _ => 0
      }
    }),
  )
}

///|
fn matrix_to_string(matrix : Matrix[Int32]) -> String {
  let str = StringBuilder()
  for i in 0..<9 {
    let row = matrix.row_to_array(i)
    str.write_char(' ')
    str.write_string(row.map(i => Int32::to_string(i)).join(" "))
    str.write_char('\n')
  }
  str.to_string()
}

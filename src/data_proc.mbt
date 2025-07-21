///|
fn is_sudoku_file(data : String, pos~ : Int = 2) -> Unit raise DataError {
  if data.length() != 81 {
    raise DataError(
      data_err_wrapper("Invalid Sudoku file length: \{data.length()}", pos),
    )
  }
}

///|
fn data_slice(raw : String) -> Array[String] {
  raw.split("\n").to_array().map(@string.View::to_string)
}

///|
fn raw_to_matrix(raw : String) -> Matrix[Int] {
  Matrix::from_array(
    9,
    9,
    raw
    .to_array()
    .map(c => match c {
      '1'..='9' => c.to_int() - '1'.to_int() + 1
      _ => 0
    }),
  )
}

///|
fn matrix_to_string(matrix : Matrix[Int]) -> String {
  let str = StringBuilder::new()
  for i in 0..<9 {
    let row = matrix.row_to_array(i)
    str.write_char(' ')
    str.write_string(row.map(i => Int::to_string(i)).join(" "))
    str.write_char('\n')
  }
  str.to_string()
}

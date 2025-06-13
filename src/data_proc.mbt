///|
fn is_sudoku_file(data : String) -> Unit raise DataError {
  if data.length() != 81 {
    raise DataError(
      ErrorData::make("data_error", "This is not a valid Sudoku file."),
    )
  }
}

///|
fn data_slice(raw : String) -> Array[String] {
  raw.split("\n").to_array().map(@string.View::to_string)
}

///|
fn raw_to_matrix(raw : String) -> Matrix[Int] {
  fn get_num(c : Char) -> Int {
    if c >= '1' && c <= '9' {
      return c.to_int() - '1'.to_int() + 1
    } else {
      return 0
    }
  }

  Matrix::from_array(9, 9, raw.to_array().map(get_num))
}

///|
fn matrix_to_raw(matrix : Matrix[Int]) -> String {
  fn get_char(i : Int) -> Char {
    if i == 0 {
      return ' '
    } else {
      return (i + '1'.to_int()).unsafe_to_char()
    }
  }

  String::from_array(matrix.to_array().map(get_char))
}

///|
fn matrix_to_string(matrix : Matrix[Int]) -> String {
  let mut str = ""
  for i in 0..<9 {
    let row = matrix.row_to_array(i)
    fn int_to_string(i : Int) -> String {
      Int::to_string(i)
    }

    str += " " + row.map(int_to_string).join(" ") + "\n"
  }
  str
}

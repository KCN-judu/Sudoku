///|
fn mask_algorithm(sudoku : Matrix[Int]) -> Matrix[Int] {
  let mask_arr = []
  for i in 0..<81 {
    mask_arr.push(Set::from_array([1, 2, 3, 4, 5, 6, 7, 8, 9]))
  }
  let mask = Matrix::from_array(9, 9, mask_arr)
  fn update_mask() -> Unit {
    for i in 0..<9 {
      for j in 0..<9 {
        if sudoku[i][j] != 0 {
          mask[i][j].clear()
          for c in 0..<9 {
            if mask[i][c].contains(sudoku[i][j]) {
              mask[i][c].remove(sudoku[i][j])
            }
            if mask[c][j].contains(sudoku[i][j]) {
              mask[c][j].remove(sudoku[i][j])
            }
          }
          let box_row = i / 3 * 3
          let box_col = j / 3 * 3
          for r in 0..<3 {
            for c in 0..<3 {
              if mask[box_row + r][box_col + c].contains(sudoku[i][j]) {
                mask[box_row + r][box_col + c].remove(sudoku[i][j])
              }
            }
          }
        }
      }
    }
  }

  fn fill_sudoku() -> Bool {
    let mut changed = false
    for i in 0..<9 {
      for j in 0..<9 {
        if mask[i][j].size() == 1 {
          sudoku[i][j] = mask[i][j].to_array()[0]
          mask[i][j].clear()
          changed = true
        }
      }
    }
    changed
  }

  update_mask()
  while fill_sudoku() {
    update_mask()
  }
  sudoku
}

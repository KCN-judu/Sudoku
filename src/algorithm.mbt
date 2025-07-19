///|
fn mask_algorithm(sudoku : Matrix[Int]) -> Matrix[Int] {
  let mask_arr = []
  for i in 0..<81 {
    mask_arr.push(Set::from_array([1, 2, 3, 4, 5, 6, 7, 8, 9]))
  }
  let mask = Matrix::from_array(9, 9, mask_arr)
  fn exclude(set : Set[Int], value : Int) -> Unit {
    if set.contains(value) {
      set.remove(value)
    }
  }

  fn update_mask() -> Unit {
    for i in 0..<9 {
      for j in 0..<9 {
        if sudoku[i][j] != 0 {
          mask[i][j].clear()
          for c in 0..<9 {
            exclude(mask[i][c], sudoku[i][j])
            exclude(mask[c][j], sudoku[i][j])
          }
          let box_row = i / 3 * 3
          let box_col = j / 3 * 3
          for r in 0..<3 {
            for c in 0..<3 {
              exclude(mask[box_row + r][box_col + c], sudoku[i][j])
            }
          }
        }
      }
    }
  }

  fn find_unique() -> Bool {
    update_mask()
    fn find_row_unique(row : Int) -> Bool {
      update_mask()
      let count = Array::make(9, (0, -1))
      for i in 0..<9 {
        if mask[row][i].size() != 0 {
          mask[row][i].each(x => count[x - 1] = (count[x - 1].0 + 1, i))
        }
      }
      let mut changed = false
      for x in 0..<9 {
        let (num, (count, index)) = (x, count[x])
        if count == 1 {
          sudoku[row][index] = num + 1
          mask[row][index].clear()
          changed = true
        }
      }
      changed
    }

    fn find_col_unique(col : Int) -> Bool {
      update_mask()
      let count = Array::make(9, (0, -1))
      for i in 0..<9 {
        if mask[i][col].size() != 0 {
          mask[i][col].each(x => count[x - 1] = (count[x - 1].0 + 1, i))
        }
      }
      let mut changed = false
      for x in 0..<9 {
        let (num, (count, index)) = (x, count[x])
        if count == 1 {
          sudoku[index][col] = num + 1
          mask[index][col].clear()
          changed = true
        }
      }
      changed
    }

    fn find_box_unique(box_row : Int, box_col : Int) -> Bool {
      update_mask()
      let count = Array::make(9, (0, (-1, -1)))
      for i in 0..<3 {
        for j in 0..<3 {
          let r = i + box_row * 3
          let c = j + box_col * 3
          if mask[r][c].size() != 0 {
            mask[r][c].each(x => count[x - 1] = (count[x - 1].0 + 1, (r, c)))
          }
        }
      }
      let mut changed = false
      for x in 0..<9 {
        let (cnt, (r, c)) = count[x]
        if cnt == 1 {
          sudoku[r][c] = x + 1
          mask[r][c].clear()
          changed = true
        }
      }
      changed
    }

    let mut changed = false
    for i in 0..<9 {
      if find_row_unique(i) || find_col_unique(i) {
        changed = true
      }
    }
    for i in 0..<3 {
      for j in 0..<3 {
        if find_box_unique(i, j) {
          changed = true
        }
      }
    }
    changed
  }

  fn fill_sudoku() -> Bool {
    update_mask()
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

  fn solve() -> Bool {
    if not(fill_sudoku() || find_unique()) {
      false
    } else {
      true
    }
  }

  while solve() {

  }
  sudoku
}

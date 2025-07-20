///|
fn candidate_algorithm(sudoku : Matrix[Int]) -> Matrix[Int] {
  let candidate = Matrix::make(9, 9, (_, _) => Set::from_array([
    1, 2, 3, 4, 5, 6, 7, 8, 9,
  ]))
  fn exclude(set : Set[Int], value : Int) -> Unit {
    if set.contains(value) {
      set.remove(value)
    }
  }

  fn update_candidate() -> Unit {
    sudoku.eachij((i, j, v) => if v != 0 {
      candidate[i][j].clear()
      candidate.each_row(i, c => exclude(c, v))
      candidate.each_col(j, c => exclude(c, v))
      for r in 0..<3 {
        for c in 0..<3 {
          let i_ = i / 3 * 3 + r
          let j_ = j / 3 * 3 + c
          if i_ != i || j_ != j {
            exclude(candidate[i_][j_], v)
          }
        }
      }
    })
  }

  fn find_unique() -> Bool {
    update_candidate()
    fn find_row_unique(row : Int) -> Bool {
      update_candidate()
      let count = Array::make(9, (0, -1))
      for i in 0..<9 {
        if candidate[row][i].size() != 0 {
          candidate[row][i].each(x => count[x - 1] = (count[x - 1].0 + 1, i))
        }
      }
      let mut changed = false
      for x in 0..<9 {
        let (num, (count, index)) = (x, count[x])
        if count == 1 {
          sudoku[row][index] = num + 1
          candidate[row][index].clear()
          changed = true
        }
      }
      changed
    }

    fn find_col_unique(col : Int) -> Bool {
      update_candidate()
      let count = Array::make(9, (0, -1))
      for i in 0..<9 {
        if candidate[i][col].size() != 0 {
          candidate[i][col].each(x => count[x - 1] = (count[x - 1].0 + 1, i))
        }
      }
      let mut changed = false
      for x in 0..<9 {
        let (num, (count, index)) = (x, count[x])
        if count == 1 {
          sudoku[index][col] = num + 1
          candidate[index][col].clear()
          changed = true
        }
      }
      changed
    }

    fn find_box_unique(box_row : Int, box_col : Int) -> Bool {
      update_candidate()
      let count = Array::make(9, (0, (-1, -1)))
      for i in 0..<3 {
        for j in 0..<3 {
          let r = i + box_row * 3
          let c = j + box_col * 3
          if candidate[r][c].size() != 0 {
            candidate[r][c].each(x => count[x - 1] = (
              count[x - 1].0 + 1,
              (r, c),
            ))
          }
        }
      }
      let mut changed = false
      for x in 0..<9 {
        let (cnt, (r, c)) = count[x]
        if cnt == 1 {
          sudoku[r][c] = x + 1
          candidate[r][c].clear()
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
    update_candidate()
    let mut changed = false
    candidate.eachij((i, j, c) => {
      if c.size() == 1 {
        sudoku[i][j] = c.to_array()[0]
        c.clear()
        changed = true
      }
    })
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

///|
/// Smoke tests that pin the current solver (naked and hidden singles). The
/// solver rewrite in #14 extends what is solved; these must keep passing.
fn solve(raw : String) -> String {
  matrix_to_string(candidate_algorithm(raw_to_matrix(raw)))
}

///|
test "an easy puzzle is solved" {
  assert_eq(
    solve(
      "530070000600195000098000060800060003400803001700020006060000280000419005000080079",
    ),
    (
      #| 5 3 4 6 7 8 9 1 2
      #| 6 7 2 1 9 5 3 4 8
      #| 1 9 8 3 4 2 5 6 7
      #| 8 5 9 7 6 1 4 2 3
      #| 4 2 6 8 5 3 7 9 1
      #| 7 1 3 9 2 4 8 5 6
      #| 9 6 1 5 3 7 2 8 4
      #| 2 8 7 4 1 9 6 3 5
      #| 3 4 5 2 8 6 1 7 9
      #|
    ),
  )
}

///|
test "a 17-clue puzzle solvable by singles is solved" {
  let out = solve(
    "000000010400000000020000000000050407008000300001090000300400200050100000000806000",
  )
  assert_false(out.contains("0"))
}

///|
test "a puzzle that needs more than singles is left unsolved (until #14)" {
  let raw = "800000000003600000070090200050007000000045700000100030001000068008500010090000400"
  assert_eq(solve(raw), matrix_to_string(raw_to_matrix(raw)))
}

///|
test "input parsing and output format" {
  assert_eq(data_slice("a\nb"), ["a", "b"])
  assert_eq(raw_to_matrix("1.3" + "0".repeat(78)).get(0, 1), 0)
  assert_eq(raw_to_matrix("1.3" + "0".repeat(78)).get(0, 2), 3)
}

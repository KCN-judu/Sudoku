///|
suberror ArgError ErrorData

///|
suberror IOError ErrorData

///|
suberror DataError ErrorData

///|
fn err_msg_with_note(err_data : ErrorData, argv : Array[String]) -> String {
  let seq = Sequence::from_array(argv)
  "\{err_data.mark(seq, marker = '^')}\n\{notice}"
}

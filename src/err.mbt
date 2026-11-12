///|
suberror ArgError {
  ArgError(ErrorData)
}

///|
suberror IOError {
  IOError(ErrorData)
}

///|
suberror DataError {
  DataError(ErrorData)
}

///|
fn err_msg_with_note(err_data : ErrorData, argv : Array[String]) -> String {
  let seq = Sequence::from_array(argv)
  "\{err_data.mark(seq, marker = '^')}\n\{notice}"
}

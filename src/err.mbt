///|
/// Errors of the CLI. Each carries an err_marker report whose marks point at
/// argument positions of `argv`; the report code is the error kind.
suberror ArgError {
  ArgError(Report)
}

///|
suberror IOError {
  IOError(Report)
}

///|
suberror DataError {
  DataError(Report)
}

///|
/// Renders an error report on the argument vector, with a hint to `help`.
fn err_msg_with_note(report : Report, argv : Array[String]) -> String {
  report.with_note(notice).render(Sequence::from_args(argv))
}

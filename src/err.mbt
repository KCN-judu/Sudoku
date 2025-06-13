///|
suberror ArgError ErrorData

///|
suberror IOError ErrorData

///|
suberror DataError ErrorData

///|
struct ErrorData {
  err_type : String
  message : String
  position : Int
}

///|
fn ErrorData::make(
  err_type : String,
  message : String,
  position~ : Int = -1
) -> ErrorData {
  ErrorData::{ err_type, message, position }
}

///|
fn args_to_string(argv : Array[String]) -> String {
  argv.join(" ")
}

///|
fn locate_arg(argv : Array[String], position : Int) -> (Int, Int) {
  let len = argv.length()
  guard position < len else { abort("Cannot locate arg: out of bounds") }
  let mut count = 0
  if position == 0 {
    return (0, argv[0].length())
  } else {
    for i in 0..<(position - 1) {
      count += argv[i].length() + 1
    }
    return (count, count + argv[position].length())
  }
}

///|
fn ErrorData::to_string(self : ErrorData, argv : Array[String]) -> String {
  let { err_type, message, position } = self
  let err_msg_body = "Error(\{err_type}): \{message}"
  if position == -1 {
    return err_msg_body
  } else {
    let (start, end) = locate_arg(argv, position)
    let err_msg_header =
      $|\{args_to_string(argv)}
      $|\{String::make(start + 1, ' ')}\{String::make(end - start, '^')}
    return "\{err_msg_header}\n\{err_msg_body}"
  }
}

///|
fn err_msg_with_note(err_data : ErrorData, argv : Array[String]) -> String {
  "\{err_data.to_string(argv)}\n\{notice}"
}

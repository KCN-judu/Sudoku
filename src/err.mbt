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
    for i in 0..<position {
      count += argv[i].length() + 1
    }
    return (count - 1, count + argv[position].length() - 1)
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
    fn start_() -> Int {
      if start == 0 {
        start
      } else {
        start + 1
      }
    }

    let err_msg_header =
      $|\{args_to_string(argv)}
      $|\{String::make(start_(), ' ')}\{String::make(end - start, '^')}
    return "\{err_msg_header}\n\{err_msg_body}"
  }
}

///|
fn err_msg_with_note(err_data : ErrorData, argv : Array[String]) -> String {
  "\{err_data.to_string(argv)}\n\{notice}"
}

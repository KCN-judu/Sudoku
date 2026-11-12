///|
fn main {
  let argv = @env.args()
  // Exit status (#13): 0 on success, 1 on an error, 2 without a command.
  if argv.length() < 2 {
    println(usage)
    @sys.exit(2)
    return
  }
  command_handler(argv) catch {
    ArgError(d) => fail_with(err_msg_with_note(d, argv))
    IOError(d) => fail_with(err_msg_with_note(d, argv))
    DataError(d) => fail_with(err_msg_with_note(d, argv))
    _ => abort("An unexpected error occurred.")
  }
}

///|
fn fail_with(message : String) -> Unit {
  println(message)
  @sys.exit(1)
}

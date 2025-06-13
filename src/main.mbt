///|
fn main {
  let argv = get_cli_args()
  command_handler(argv) catch {
    ArgError(msg) => println(err_msg_with_note(msg, argv))
    IOError(msg) => println(err_msg_with_note(msg, argv))
    DataError(msg) => println(err_msg_with_note(msg, argv))
    _ => abort("An unexpected error occurred.")
  }
}

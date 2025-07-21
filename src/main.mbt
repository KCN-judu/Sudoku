///|
fn main {
  let argv = get_cli_args()
  command_handler(argv) catch {
    ArgError(d) => println(err_msg_with_note(d, argv))
    IOError(d) => println(err_msg_with_note(d, argv))
    DataError(d) => println(err_msg_with_note(d, argv))
    _ => abort("An unexpected error occurred.")
  }
}

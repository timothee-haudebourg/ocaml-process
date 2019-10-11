type t

exception Crash

type status =
  | Ok
  | Error

val create: ?env:string array -> string -> t

val stdout: t -> in_channel

val stderr: t -> in_channel

val stdin: t -> out_channel

val close: t -> status

val exec: string -> string

(* val whereis: string -> string *)

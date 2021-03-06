exception Crash

type status =
  | Ok
  | Error

type t = {
  stdout: in_channel;
  stderr: in_channel;
  stdin: out_channel;
  mutable status: status option
}

(* type result = status * string * string *)

let get_status = function
  | Unix.WEXITED 0 -> Ok
  | _ -> Error

let close t =
  match t.status with
  | Some status -> status
  | None ->
    let exit_status = Unix.close_process_full (t.stdout, t.stdin, t.stderr) in
    let status = get_status exit_status in
    t.status <- Some status;
    status

let finalise t =
  ignore (close t)

let create ?(env=Unix.environment ()) cmd =
  let oc, ic, ec = Unix.open_process_full cmd env in
  let t = {
    stdout = oc;
    stderr = ec;
    stdin = ic;
    status = None
  } in
  Gc.finalise finalise t;
  t

let stdout t = t.stdout

let stderr t = t.stderr

let stdin t = t.stdin

let exec cmd =
  let p = create cmd in
  let channel = stdout p in
  let out = ref "" in
  begin
    try
      while true do
        out := !out ^ "\n" ^ (input_line channel)
      done
    with
    | End_of_file ->
      begin
        match close p with
        | Ok -> ()
        | Error -> raise Crash
      end
  end;
  !out

(* let whereis name =
   match String.split_on_char '\n' (Process.exec ("whereis -b "^name)) with
   | Some results ->
    (* ... *)
   | None -> failwith (Invalid_argument "no binary found") *)

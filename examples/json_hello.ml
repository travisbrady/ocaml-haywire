(*
open Ctypes
open Printf

type message = {message: string} [@@deriving yojson]

let fresh_message () =
  {message="Hello, World!"}
  |> message_to_yojson
  |> Yojson.Safe.to_string

let complete = (fun x -> ())

let get_root req resp user_data =
  Haywire.set_response_status_code resp "200 OK";
  Haywire.set_body resp "HELLO!";
  Haywire.set_response_header resp "Content-Type" "application/json";
  if (Haywire.request_get_keep_alive req) > 0 then
    Haywire.set_response_header resp "Connection" "Keep-Alive"
  else
    Haywire.set_http_version resp 1 0;
  Haywire.hw_http_response_send resp null complete;
  ()

let () =
  let config = Haywire.make_config "0.0.0.0" 8000 in
  Haywire.hw_init_with_config (addr config);
  Haywire.hw_http_add_route "/json" get_root null;
  Haywire.hw_http_open 32;
  ()

*)

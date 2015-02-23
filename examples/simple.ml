open Ctypes
open Printf

let complete = (fun _ -> ())

let make_ud () =
  let out = allocate_n Ctypes.string ~count:9 in
  out <-@ "user_data";
  to_voidp out

let ud = make_ud ()

let ctr = ref 0
let status_code = "200 OK"
let body = "Hello, World!"
let ct = "Content-Type"
let tp = "text/plain"
let conn = "Connection"
let keep_alive = "Keep-Alive"

let get_root req resp user_data =
  incr ctr;
  let sc = Haywire.set_response_status_code resp status_code in
  let k, v = Haywire.set_response_header resp ct tp in
  let _body = Haywire.set_body resp body in
  (*
  Haywire.hw_set_response_status_code resp status_code;
  Haywire.hw_set_body resp body;
  Haywire.hw_set_response_header resp ct tp;
  *)
  if (Haywire.request_get_keep_alive req) > 0 then
      let _conn, _ka = Haywire.set_response_header resp conn keep_alive in
      ()
  else
    Haywire.set_http_version resp 1 0;
  (*Haywire.fake_response req resp;*)
  Haywire.hw_http_response_send resp user_data complete;
  (*if !ctr mod 200 = 0 then Gc.full_major ();*)
  ()

let () =
  let config = Haywire.make_config "0.0.0.0" 8000 in
  Haywire.hw_init_with_config (addr config);
  Haywire.hw_http_add_route "/" get_root null;
  Haywire.hw_http_open 0;
  eprintf "%s %s %s %s %s %s\n" status_code body ct tp conn keep_alive;
  ()


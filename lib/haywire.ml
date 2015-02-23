open Ctypes
open Foreign
open Unsigned

type configuration
let configuration : configuration structure typ = structure "configuration"
let http_listen_address = field configuration "http_listen_address" string
let http_listen_port = field configuration "http_listen_port" int
let () = seal configuration

let make_config addr port =
  let config = make configuration in
  let () = begin
    setf config http_listen_address addr;
    setf config http_listen_port port
  end
  in
  config

type hw_string
let hw_string : hw_string structure typ = structure "hw_string"
let value = field hw_string "value" string
let length = field hw_string "length" size_t
let () = seal hw_string

let make_hw_string s =
  let hws = make hw_string in
  let () = begin
    setf hws value s;
    setf hws length (Size_t.of_int (String.length s))
  end
  in
  hws

type http_request
let http_request : http_request structure typ = structure "http_request"
let http_major = field http_request "http_major" ushort
let http_minor = field http_request "http_minor" ushort
let _method = field http_request "method" uchar
let keep_alive = field http_request "keep_alive" int
let url = field http_request "url" string
let headers = field http_request "headers" (ptr void)
let body = field http_request "body" (ptr hw_string)
let body_length = field http_request "body_length" int
let () = seal http_request

let request_get_keep_alive req = getf (!@req) keep_alive

let from = Dl.(dlopen ~filename:"libhaywire.dylib" ~flags:[RTLD_NOW])

let http_response = ptr void
let http_request_callback = funptr (ptr http_request @-> ptr http_response @-> ptr void @-> returning void)

let hw_init_from_config = foreign ~from "hw_init_from_config" (string @-> returning int)
let hw_init_with_config = foreign ~from "hw_init_with_config" (ptr configuration @-> returning int)
let hw_http_open = foreign ~from "hw_http_open" (int @-> returning int)
let hw_http_add_route = foreign ~from "hw_http_add_route" (string @-> http_request_callback @-> ptr void @-> returning void)
let hw_get_header = foreign ~from "hw_get_header" (ptr http_request @-> string @-> returning string)

let hw_free_http_response = foreign ~from "hw_free_http_response" (ptr http_response @-> returning void)
let hw_set_http_version = foreign ~from "hw_set_http_version" (ptr http_response @-> ushort @-> ushort @-> returning void)
let hw_set_response_status_code = foreign ~from "hw_set_response_status_code" (ptr http_response @-> ptr hw_string @-> returning void)
let hw_set_response_header = foreign ~from "hw_set_response_header" (ptr http_response @-> ptr hw_string @-> ptr hw_string @-> returning void)
let hw_set_body = foreign ~from "hw_set_body" (ptr http_response @-> ptr hw_string @-> returning void)

let complete_callback = funptr (ptr void @-> returning void)
let hw_http_response_send = foreign ~from "hw_http_response_send" (ptr http_response @-> ptr void @-> complete_callback @-> returning void)

let hw_print_request_headers = foreign ~from "hw_print_request_headers" (ptr http_request @-> returning void)

let set_http_version resp major minor =
  hw_set_http_version resp (UShort.of_int major) (UShort.of_int minor)

let set_response_status_code resp code =
  let _code = addr (make_hw_string code) in
  hw_set_response_status_code resp _code;
  _code

let set_response_header resp name value =
  let _name = addr (make_hw_string name) in
  let _value = addr (make_hw_string value) in
  hw_set_response_header resp _name _value;
  _name, _value

let set_body resp body_str =
  let _body = addr (make_hw_string body_str) in
  hw_set_body resp _body;
  _body

let from2 = Dl.(dlopen ~filename:"dllhaywire_stubs.so" ~flags:[RTLD_NOW])
let fake_response = foreign ~from:from2 "fake_response" (ptr http_request @-> ptr http_response @-> returning void)

let c_hw_set_response_status_code = foreign ~from:from2 "c_hw_set_response_status_code" (ptr http_response @-> string @-> returning void)
let c_hw_set_response_header = foreign ~from:from2 "c_hw_set_response_header" (ptr http_response @-> string @-> string @-> returning void)
let c_hw_set_body = foreign ~from:from2 "c_hw_set_body" (ptr http_response @-> string @-> returning void)

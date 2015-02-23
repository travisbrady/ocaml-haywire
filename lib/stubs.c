#include <string.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/bigarray.h>

#include "haywire.h"

void fake_response(http_request* request, hw_http_response* response) {
    hw_string status_code;
    hw_string content_type_name;
    hw_string content_type_value;
    hw_string body;
    hw_string keep_alive_name;
    hw_string keep_alive_value;

    SETSTRING(status_code, HTTP_STATUS_200);
    hw_set_response_status_code(response, &status_code);

    SETSTRING(content_type_name, "Content-Type");

    SETSTRING(content_type_value, "text/html");
    hw_set_response_header(response, &content_type_name, &content_type_value);

    SETSTRING(body, "hello world");
    hw_set_body(response, &body);

    if (request->keep_alive)
    {
        SETSTRING(keep_alive_name, "Connection");

        SETSTRING(keep_alive_value, "Keep-Alive");
        hw_set_response_header(response, &keep_alive_name, &keep_alive_value);
    }
    else
    {
        hw_set_http_version(response, 1, 0);
    }
}

void c_hw_set_response_status_code(hw_http_response* response, char* status_code) {
    hw_string h_status_code;
    size_t l = strlen(status_code);
    h_status_code.value = status_code;
    h_status_code.length = l;
    hw_set_response_status_code(response, &h_status_code);
}

void c_hw_set_response_header(hw_http_response* response, char* name, char* value) {
    hw_string h_name;
    size_t l = strlen(name);
    h_name.value = name;
    h_name.length = l;

    hw_string h_value;
    size_t lv = strlen(value);
    h_value.value = value;
    h_value.length = lv;
    hw_set_response_header(response, &h_name, &h_value);
}

void c_hw_set_body(hw_http_response* response, char* body) {
    hw_string hws;
    size_t l = strlen(body);
    hws.value = body;
    hws.length = l;
    hw_set_body(response, &hws);
}


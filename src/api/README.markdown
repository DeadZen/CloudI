# CloudI API

## PURPOSE

Provide an interface for external software to utilize CloudI's scalability,
fault-tolerance, messaging, dynamic configuration, and other features.

## INTEGRATION

### Supported languages:

* Erlang >= R14B02
* C++
* C
* Java
* Python >= 2.7.0
* Ruby >= 1.9.0

For Erlang integration, use the cloudi_job behavior which is included within
the cloudi_core application.  The Erlang code is expected to run in a separate
application within the same Erlang VM as CloudI.  Erlang supports writing
very robust software but Erlang development within CloudI requires more
scrutiny because the Erlang code can easily access CloudI internals to
bypass the ACL functionality and manipulate the system in malicious ways.

C++/C, Java, Python, and Ruby all use the same function names that exist within
the cloudi_job Erlang behavior, but each language makes function calls into
its own native CloudI library.  The external languages are ran as separate
OS processes with separate threads (using any native threading library) that
initialize the CloudI API and call its event-loop (in the "poll" function).

### Examples exist within the tests:

* [Erlang](https://github.com/okeuday/CloudI/blob/master/src/tests/hexpi/src/cloudi_job_hexpi.erl) (hexpi test controller)
* [C++](https://github.com/okeuday/CloudI/blob/master/src/tests/hexpi/cxx_src/main.cpp) (hexpi test worker threads)
* [C](https://github.com/okeuday/CloudI/blob/master/src/tests/http_req/c_src/main.c) (http_req test HTTP handler)
* [Java](https://github.com/okeuday/CloudI/tree/master/src/tests/http_req/org/cloudi/tests/http_req) (http_req test HTTP handler)
* [Python](https://github.com/okeuday/CloudI/blob/master/src/tests/http_req/http_req.py) (http_req test HTTP handler)
* [Python (using C integration)](https://github.com/okeuday/CloudI/blob/master/src/tests/http_req/http_req_c.py) (http_req test HTTP handler)
* [Ruby](https://github.com/okeuday/CloudI/blob/master/src/tests/http_req/http_req.rb) (http_req test HTTP handler)

Please see the [FAQ](http://cloudi.org/faq.html) for more details
(more integration documentation will be added soon).


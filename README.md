# Plug.Routes

This library implements the command `mix plug.routes`.

## Usage

When passed the name of a Plug router module, it lists
all defined routes.

Example:
```sh
$ mix plug.routes MyPlug
Verb       Path
GET        /articles
GET        /articles/:id
POST, PUT  /articles/:id
*          /*anything
```

Note that `*` indicates a route that accepts any HTTP verb.

## Implementation

Plug routes are macro-defined private methods.

In order to list these routes, this library uses a fair bit of
implementation-specific code, so it may break with future changes to Plug.

Process:

* The `BeamAnalyzer` library is used to list all `do_match/3` functions defined in
the supplied module.
* The information to be listed is extracted from the function clauses returned.
  * The first parameter to the function, if it is a string is taken to be the HTTP
    verb that the route responds to.
  * The second parameter to the function is the path indicator.
  * Guard clauses are also checked for `via:` - the verb indicator.

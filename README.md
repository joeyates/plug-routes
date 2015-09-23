# Plug.Routes [![Build Status](https://api.travis-ci.org/joeyates/plug-routes.svg)][Continuous Integration]
Provides the mix command `mix plug.routes`.

[Source Code]: https://github.com/joeyates/plug-routes "Source code at GitHub"
[Continuous Integration]: http://travis-ci.org/joeyates/plug-routes "Build status by Travis-CI"

# Add to a project

mix.exs:
```
...
  defp deps do
    [
      {:plug_routes, ">= 0.0.2"}
    ]
  end
...
```

# Usage

When passed the name of a Plug router module, it lists
all defined routes.

## Example

With these routes:

```elixir
defmodule MyRouter do
  use Plug.Router

  plug :match

  match "/articles" do
    conn |> resp(200, "articles")
  end

  get "/articles/:id" do
    conn |> resp(200, "an article")
  end

  match "/articles/:id", via: [:post, :put] do
    conn |> resp(200, "updated an article")
  end

  match "*anything" do
    conn |> resp(200, "articles")
  end
end
```

```sh
$ mix plug.routes MyRouter
Verb       Path
GET        /articles
GET        /articles/:id
POST, PUT  /articles/:id
*          /*anything
```

Note that `*` indicates a route that accepts any HTTP verb.

# Implementation

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
  * Guard clauses are also checked for `via:` - the HTTP verb indicator.

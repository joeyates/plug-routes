defmodule Mix.Tasks.Plug.RoutesTest do
  use PlugRoutesCase
  import ExUnit.CaptureIO

  test "it lists routes", _context do
    fun = fn ->
      Mix.Tasks.Plug.Routes.run(["APlugRouter"])
    end

    expected = """
Verb       Path
*          /any_verb
POST       /match_post
POST, GET  /match_get_or_post
GET        /get
GET        /path/elements
GET        /with_variable/:bar
"""

    result = capture_io(fun)

    assert result == expected
  end
end

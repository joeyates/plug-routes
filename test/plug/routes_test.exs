defmodule Plug.RoutesTest do
  use PlugRoutesCase

  """
  To understand this test, look at test/fixtures/a_plug_router.ex
  """

  test ".analyze_routes/1 returns keyword lists of paths and verbs", context do
    {:ok, routes} = Plug.Routes.analyze_routes(context[:module])
    expected = [
      [path: ["any_verb"], verbs: ["*"]],
      [path: ["match_post"], verbs: ["POST"]],
      [path: ["match_get_or_post"], verbs: ["POST", "GET"]],
      [path: ["get"], verbs: ["GET"]],
      [path: ["path", "elements"], verbs: ["GET"]],
      [path: ["with_variable", :bar], verbs: ["GET"]],
    ]
    assert routes == expected
  end

  test ".list_routes/1 lists routes as strings", context do
    {:ok, routes} = Plug.Routes.list_routes(context[:module])
    expected = [
      "* /any_verb",
      "POST /match_post",
      "POST, GET /match_get_or_post",
      "GET /get",
      "GET /path/elements",
      "GET /with_variable/:bar"
    ]
    assert routes == expected
  end
end

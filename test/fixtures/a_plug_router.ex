defmodule APlugRouter do
  use Plug.Router

  plug :match

  match "/any_verb" do
    conn |> resp(200, "the response")
  end

  match "/match_post", via: [:post] do
    conn |> resp(200, "the response")
  end

  match "/match_get_or_post", via: [:get, :post] do
    conn |> resp(200, "the response")
  end

  get "/get" do
    conn |> resp(200, "the response")
  end

  post "/post" do
    conn |> resp(200, "the response")
  end

  delete "/delete" do
    conn |> resp(200, "the response")
  end

  get "/path/elements" do
    conn |> resp(200, "the response")
  end

  get "/with_variable/:bar" do
    conn |> resp(200, "bar = #{bar}")
  end

  match "/with/*glob" do
    conn |> resp(200, "matched #{glob}")
  end
end

defmodule Plug.Routes do
  alias BeamAnalyzer

  defp string_from_bin({:bin_element, _line, {:string, _, char_list}, :default, :default}) do
    to_string(char_list)
  end

  defp verbs_from_param0({:clause, _, [{:var, _, _}, _, _], _guards, _body}) do
    []
  end

  defp verbs_from_param0({:clause, _line1, [{:bin, _line2, [bin]}, _, _], _guards, _body}) do
    [string_from_bin(bin)]
  end

  defp verbs_from_guard_alternatives({:op, _, :"=:=", _a1, {:bin, _, [bin]}}) do
    [string_from_bin(bin)]
  end

  defp verbs_from_guard_alternatives({:op, _, :orelse, a1, a2}) do
    verbs_from_guard_alternatives(a1) ++ verbs_from_guard_alternatives(a2)
  end

  defp verbs_from_guards({:clause, _line1, [{:bin, _, _}, _, _], _guards, _body}) do
    []
  end

  defp verbs_from_guards({:clause, _line1, [{:var, _, _}, _, _], [[{:atom, 0, true}]], _body}) do
    ["*"]
  end

  defp verbs_from_guards({:clause, _line1, [{:var, _, _}, _, _], xxx, _body}) do
    {:ok, foo} = Enum.fetch(xxx, 0)
    {:ok, bar} = Enum.fetch(foo, 0)
    verbs_from_guard_alternatives(bar)
  end

  defp variable_path_element_from_var(var) do
    [element, _] = String.split(to_string(var), "@")
    String.to_atom(element)
  end

  defp path_elements_from_cons({:cons, _, {:bin, _, [bin]}, {:nil, _}}) do
    [string_from_bin(bin)]
  end

  defp path_elements_from_cons({:cons, _, {:bin, _, [bin]}, cons}) do
    [string_from_bin(bin) | path_elements_from_cons(cons)]
  end

  defp path_elements_from_cons({:cons, _, {:var, _, name}, {nil, _}}) do
    [variable_path_element_from_var(name)]
  end

  defp path_elements_from_cons({:cons, _, {:var, _, name}, cons}) do
    [variable_path_element_from_var(name) | path_elements_from_cons(cons)]
  end

  defp path_elements_from_param1({:clause, _, [_, path_cons, _], _, _}) do
    path_elements_from_cons(path_cons)
  end

  defp verbs_from_route(route) do
    verbs_from_guards(route) ++ verbs_from_param0(route)
  end

  defp analyze_route(match) do
    verbs = verbs_from_route(match)
    path = path_elements_from_param1(match)
    [path: path, verbs: verbs]
  end

  defp do_analyze_routes([match | rest]) do
    [analyze_route(match) | do_analyze_routes(rest)]
  end

  defp do_analyze_routes([]) do
    []
  end

  def analyze_routes(module) do
    case BeamAnalyzer.function(module, :do_match, 3) do
      {:ok, do_match_clauses} ->
        {:ok, do_analyze_routes(do_match_clauses)}
      {:error, :not_found} ->
        {:error, "No do_match clauses found in that module"}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def list_routes(module) do
    case analyze_routes(module) do
      {:ok, routes} ->
        list = for route <- routes do
          Enum.join(route[:verbs], ", ") <> " " <>
          path_elements_to_route(route[:path])
        end
        {:ok, list}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def path_elements_to_route(elements) do
    parts = for elem <- elements do
      if is_atom(elem) do
        ":" <> to_string(elem)
      else
        elem
      end
    end
    "/" <> Enum.join(parts, "/")
  end
end

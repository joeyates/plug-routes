defmodule Plug.Routes do
  alias BeamAnalyzer

  defp string_from_bin({:bin_element, _line, {:string, _, char_list}, :default, :default}) do
    to_string(char_list)
  end

  defp verbs_from_param({:var, _, _}) do
    nil
  end

  defp verbs_from_param({:bin, _line2, [bin]}) do
    [string_from_bin(bin)]
  end

  defp verbs_from_guard_alternatives({:op, _, :"=:=", _a1, {:bin, _, [bin]}}) do
    [string_from_bin(bin)]
  end

  defp verbs_from_guard_alternatives({:op, _, :orelse, a1, a2}) do
    verbs_from_guard_alternatives(a1) ++ verbs_from_guard_alternatives(a2)
  end

  defp verbs_from_guards([[{:atom, 0, true}]]) do
    ["*"]
  end

  defp verbs_from_guards([[alternatives | _] | _]) do
    verbs_from_guard_alternatives(alternatives)
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

  defp do_analyze_route(verb, path_cons, guards) do
    verbs = verbs_from_param(verb) || verbs_from_guards(guards)
    path = path_elements_from_cons(path_cons)
    [path: path, verbs: verbs]
  end

  # Plug 0.13.0
  defp analyze_route({:clause, _line1, [verb, path_cons, _], guards, _body}) do
    do_analyze_route(verb, path_cons, guards)
  end

  # Plug 0.13.1
  defp analyze_route({:clause, _line1, [_conn, verb, path_cons, _], guards, _body}) do
    do_analyze_route(verb, path_cons, guards)
  end

  defp do_analyze_routes([match | rest]) do
    [analyze_route(match) | do_analyze_routes(rest)]
  end

  defp do_analyze_routes([]) do
    []
  end

  defp plug_version do
    lock = Mix.Dep.Lock.read
    plug = lock[:plug]
    if plug do
      {:ok, elem(plug, 2)}
    else
      {:err, :plug_not_found}
    end
  end

  defp do_match_clauses(module) do
    case plug_version() do
      {:err, reason} ->
        {:err, reason}
      {:ok, "0.13.0"} ->
        BeamAnalyzer.function(module, :do_match, 3)
      {:ok, _version} ->
        BeamAnalyzer.function(module, :do_match, 4)
    end
  end

  def analyze_routes(module) do
    case do_match_clauses(module) do
      {:ok, clauses} ->
        {:ok, do_analyze_routes(clauses)}
      {:error, :plug_not_found} ->
        {:error, "Plug does not seem to be a dependency of this project"}
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

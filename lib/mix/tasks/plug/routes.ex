defmodule Mix.Tasks.Plug.Routes do
  use Mix.Task

  @shortdoc "List the Plug routes defined in a module"

  def run(args) do
    if length(args) > 0 do
      {:ok, module_name} = Enum.fetch(args, 0)
      case find_module_by_name(module_name) do
        {:ok, module} ->
          case Plug.Routes.analyze_routes(module) do
            {:ok, routes} ->
              print_routes(routes)
            {:error, reason} ->
              IO.puts "Error: #{reason}"
          end
        {:error, :not_found} ->
          IO.puts "Module '#{module_name}' not found"
      end
    else
      IO.puts "Please supply a name"
    end
  end

  # The following 3 functions are inspired by Phoenix's
  # lib/router/console_formatter.ex
  defp print_routes(routes) do
    verb_width = calculate_verb_width(routes)
    IO.puts format("Verb", verb_width, "Path")
    IO.puts Enum.map_join(routes, "\n", &print_route(&1, verb_width))
  end

  defp print_route(route, verb_width) do
    verbs = Enum.join(route[:verbs], ", ")
    path = Plug.Routes.path_elements_to_route(route[:path])
    format(verbs, verb_width, path)
  end

  defp format(verb, verb_width, path) do
    String.ljust(verb, verb_width) <> "  " <> path
  end

  defp calculate_verb_width(routes) do
    base = String.length("Verb")
    Enum.reduce routes, base, fn(route, verb_width) ->
      verbs = Enum.join(route[:verbs], ", ")
      max(verb_width, String.length(verbs))
    end
  end

  defp find_module_by_name(module_name) do
    modules = :erlang.loaded()
    qualified_name = "Elixir." <> module_name
    find_module_by_name_in_list(qualified_name, modules)
  end

  defp find_module_by_name_in_list(qualified_name, [h | t]) do
    if qualified_name === to_string(h) do
      {:ok, h}
    else
      find_module_by_name_in_list(qualified_name, t)
    end
  end

  defp find_module_by_name_in_list(_qualified_name, []) do
    {:error, :not_found}
  end
end

defmodule PlugRoutesCase do
  use ExUnit.CaseTemplate

  setup do
    source_fixture_path = "test/fixtures/a_plug_router.ex"
    [{module, _}] = :elixir_compiler.file_to_path(source_fixture_path, ".")

    on_exit fn ->
      File.rm("Elixir.APlugRouter.beam")
      # Remove module to avoid "redefining module APlugRouter" warning
      :code.delete(APlugRouter)
      :code.purge(APlugRouter)
      Code.unload_files([source_fixture_path])
    end

    {:ok, [module: module]}
  end
end

ExUnit.start()

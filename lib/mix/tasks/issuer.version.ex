defmodule Mix.Tasks.Issuer.Version do
  use Mix.Task

  @shortdoc  "Fixes `mix.exs` for Issuer, putting verion into VERSION file"
  @moduledoc @shortdoc

  @doc false
  def run(_) do
    case Issuer.Utils.version? do
      {:version!, version} ->
        IO.puts "​⚑ Misconfiguration detected: version was not found. `VERSION` file was written."
        version
      {:mix!, version} ->
        IO.puts "⚐ Version updated in both `mix.exs` and `VERSION` files"
        version
      {:ok, version} -> version
    end
    :ok
  end
end

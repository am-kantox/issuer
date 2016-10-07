defmodule Mix.Tasks.Issuer do
  use Mix.Task

  @shortdoc  "Issues the package to hex.pm" # (use `--help` for options)" BAH not yet
  @moduledoc @shortdoc

  @doc false
  def run(argv) do
    case prerequisites?() do
      {:fail, :version} -> Mix.Tasks.Issuer.Version.run(argv)
      {:fail, :env}     -> Mix.Tasks.Issuer.Init.run(argv)
    end
    Mix.Tasks.Test.run(argv)
  end

  defp prerequisites? do
    cond do
      Issuer.Utils.version_in_mix? -> {:fail, :version}
      true -> :ok
    end
  end
end

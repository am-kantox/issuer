defmodule Mix.Tasks.Issuer do
  use Mix.Task

  @shortdoc  "Issues the package to hex.pm" # (use `--help` for options)" BAH not yet
  @moduledoc @shortdoc

  @doc false
  def run(argv) do
    case prerequisites?() do
      {:fail, :version} -> Mix.Tasks.Issuer.Version.run(argv)
      {:fail, :env}     -> Mix.Tasks.Issuer.Init.run(argv)
      :ok               -> run_everything(argv)
    end

  end

  ##############################################################################

  defp prerequisites? do
    cond do
      Issuer.Utils.version_in_mix?() -> {:fail, :version}
      true -> :ok
    end
  end

  defp run_everything(argv) do
    run_tests(argv)
  end

  defp run_tests(argv) do
    IO.puts ~S"""
    ===========================================================================
    Running tests...
    ———————————————————————————————————————————————————————————————————————————
    """
    mix_env = Mix.env
    Mix.env(:test)
    result = Mix.Tasks.Test.run(argv)

    IO.puts "———————————————————————————————————————————————————————————————————————————"
    case result do
      :ok   -> Bunt.puts([:green, "✓ tests succeeded"])
      fails -> Bunt.puts([:red, "✗ #{fails |> Enum.count} tests failed"])
    end
    Mix.env(mix_env)
    IO.puts ~S"""
    ===========================================================================
    """
  end
end

defmodule Mix.Tasks.Issuer do
  use Mix.Task

  @shortdoc  "Issues the package to hex.pm" # (use `--help` for options)" BAH not yet
  @moduledoc @shortdoc

  @doc false
  def run(argv) do
    case prerequisites?() do
      {:fail, :version} -> Mix.Tasks.Issuer.Version.run(argv)
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
    mix_env = Mix.env
    Mix.env(:test)
    step("tests", fn argv -> Mix.Tasks.Test.run(argv) end, argv)
    Mix.env(mix_env)
  end

  ##############################################################################

  @delim "———————————————————————————————————————————————————————————————————————————"
  @super "==========================================================================="
  defp step(title, fun, opts \\ [])do
    IO.puts @super
    Bunt.puts [:bright, "⇒", :reset, " Running “", :bright, title, :reset, "”..."]
    IO.puts @delim

    result = fun.(opts)

    IO.puts @delim
    case result do
      :ok   -> Bunt.puts([:green, :bright, "✓", :reset, " “", :bright, title, :reset, "” ", :green, "succeeded."])
      fails ->
        Bunt.puts([:red, :bright, "✗", :reset, " “", :bright, title, :reset, "” ", :red, "failed.", :reset, " Returned:"])
        IO.puts @delim
        Bunt.puts([:yellow, inspect(fails)])
    end
    IO.puts @super
  end
end

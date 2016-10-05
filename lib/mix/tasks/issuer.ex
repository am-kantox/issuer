defmodule Mix.Tasks.Issuer do
  use Mix.Task

  @shortdoc  "Issues the package to hex.pm (use `--help` for options)"
  @moduledoc @shortdoc

  @doc false
  def run(argv) do
    Issuer.main(argv)
  end
end

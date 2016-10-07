defmodule Mix.Tasks.Issuer.Init do
  use Mix.Task

  @shortdoc  "Helps to get into Issuer, creates all the necessary snippets"
  @moduledoc @shortdoc

  @doc false
  def run(_) do
    Issuer.Github.welcome_setup
  end
end

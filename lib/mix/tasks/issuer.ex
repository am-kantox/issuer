defmodule Mix.Tasks.Issuer do
  @shortdoc  "Issues the package to hex.pm" # (use `--help` for options)" BAH not yet
  @moduledoc @shortdoc

  use Mix.Task
  alias Issuer.CLI.IO.Ncurses, as: CLI

  @doc false
  def run(argv) do
    case prerequisites?() do
      {:fail, :version} -> Mix.Tasks.Issuer.Version.run(argv)
      :ok               -> everything!(argv)
    end

  end

  ##############################################################################

  defp prerequisites? do
    cond do
      Issuer.Utils.version_in_mix?() -> {:fail, :version}
      true -> :ok
    end
  end

  defp everything!(argv) do
#    [:tests!, :status!, :version!]
    [:version!]
      |> Enum.all?(fn f -> apply(Mix.Tasks.Issuer, f, [argv]) end)
  end

  def tests!(argv) do
    fun = fn argv -> Mix.Tasks.Test.run(argv) end
    callback = fn result -> "Failed tests count: #{result |> Enum.count}." end

    mix_env = Mix.env
    Mix.env(:test)
    step("tests", fun, callback, argv)
    Mix.env(mix_env)
  end

  def status!(argv) do
    # FIXME NOT HARDCODE GIT
    fun = fn _ -> %Issuer.Git{} |> Issuer.Vcs.status end
    callback = fn result ->
      case result do
        {:changes, files} -> ["Unstaged changes:\n", files |> String.trim_trailing]
        other -> ["Unknown error: ", inspect(other)]
      end
    end
    step("git status", fun, callback, argv)
  end

  def version!(argv) do
    # FIXME NOT HARDCODE GIT
    fun = fn _ ->
      tags = %Issuer.Git{}
               |> Issuer.Vcs.tags
               |> Enum.filter(&Issuer.Utils.version_valid?/1)
               |> Issuer.Utils.leaves
      questions = [
        %Issuer.CLI.Question.Variant{
          title: "Please select a version you want to bump to",
          choices: tags,
          choice: 0,
        } |> Issuer.CLI.Question.to_question,
      ]
      answer = CLI.survey! "I need some more information.", questions
      IO.inspect answer
    end
    callback = fn result ->
      case result do
        # {:changes, files} -> ["Unstaged changes:\n", files |> String.trim_trailing]
        other -> ["Unknown error: ", inspect(other)]
      end
    end
    step("analyzing tags", fun, callback, argv)
  end

  ##############################################################################

  @delim "———————————————————————————————————————————————————————————————————————————"
  @super "==========================================================================="
  defp step(title, fun, callback \\ nil, opts \\ [])do
    IO.puts ""
    IO.puts @super
    Bunt.puts [:bright, "⇒", :reset, " Running “", :bright, title, :reset, "”…"]
    IO.puts @delim

    result = fun.(opts)

    case result do
      :ok   ->
        Bunt.puts([:green, :bright, "✓", :reset, " “", :bright, title, :reset, "” ", :green, "succeeded."])
        IO.puts @super
        true
      fails ->
        message = [:red, :bright, "✗", :reset, " “", :bright, title, :reset, "” ", :red, "failed.", :reset]
        addendum = if callback, do: [" Details:\n", @delim, "\n", :yellow, callback.(fails)], else: []
        Bunt.puts(message ++ addendum)
        IO.puts @super
        false
    end
  end
end

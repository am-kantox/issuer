defmodule Mix.Tasks.Issuer do
  @shortdoc  "Issues the package to hex.pm" # (use `--help` for options)" BAH not yet
  @moduledoc @shortdoc

  use Mix.Task

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
    [:tests!, :survey!, :readme!, :commit!, :status!, :hex!]
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

  def survey!(argv) do
    fun = fn _ ->
      tags = %Issuer.Git{}
               |> Issuer.Vcs.tags
               |> Enum.filter(&Issuer.Utils.version_valid?/1)
               |> Issuer.Utils.sprouts
      questions = [
        %Issuer.CLI.Question.Variant{
          title: "Please select a version you want to bump to",
          choices: tags,
          choice: 0,
        } |> Issuer.CLI.Question.to_question
      ]
      title = "I need some more information."
      survey_base = if Code.ensure_loaded?(ExNcurses) do
                      %Issuer.CLI.IO.Ncurses{title: title, questions: questions}
                    else
                      %Issuer.CLI.IO.Gets{title: title, questions: questions}
                    end
      [index] = survey_base |> Issuer.Survey.survey!
      case Issuer.Utils.version!(tags |> Enum.at(index)) do
        {:ok, version} -> :ok
        other -> other
      end
    end
    callback = fn result -> ["Invalid version: ", inspect(result)] end
    step("resetting version", fun, callback, argv)
  end

  def readme!(argv) do
    fun = fn argv ->
      case Issuer.Utils.version? do
        {:ok, version} ->
          # [{:issuer, "~> 0.1.0"}]
          File.write!("README.md", Regex.replace(
            ~r|{\s*#{inspect(Mix.Project.config[:app])},\s*"~>[^"]+"|,
            File.read!("README.md"),
            ~s|{#{inspect(Mix.Project.config[:app])}, "~> #{version}"|
          ))
          :ok
        other -> other
      end
    end
    callback = fn result -> ["Fail to update README: ", inspect(result)] end
    step("README", fun, callback, argv)
  end

  def commit!(argv) do
    # FIXME NOT HARDCODE GIT
    fun = fn _ ->
      {:ok, version} = Issuer.Utils.version?
      %Issuer.Git{} |> Issuer.Vcs.commit!(":paperclip: Bump to version #{version}.")
      %Issuer.Git{} |> Issuer.Vcs.tag!(version |> Issuer.Utils.prefix_version)
    end
    callback = fn result -> ["Unknown error: ", inspect(result)] end
    step("committing changes", fun, callback, argv)
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

  def hex!(argv) do
    fun = fn argv ->
      Mix.Tasks.Hex.Build.run(argv)
      Mix.Tasks.Hex.Publish.run(argv)
    end
    callback = fn result -> "Got an error from Hex: #{inspect(result)}." end

    step("publishing to hex", fun, callback, argv)
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

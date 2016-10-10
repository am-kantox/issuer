defmodule Issuer.Git do
  alias Issuer.CLI.IO.Ncurses, as: CLI
  alias Issuer.CLI.Question
  alias Issuer.CLI.Question.Input

  @moduledoc """
  """

  defstruct status: nil

  defimpl Issuer.Vcs, for: Issuer.Git do
    @doc """
      Lists tags for the repository given.
    """
    def tags(data) do
      case System.cmd("git", ["tag"]) do
        {result, 0} -> result |> String.split
        {_, 128}    -> Mix.raise("Not a git repository. Please run `git init` here first.")
        {err, _}    -> Mix.raise("Unknown error. Message: #{err}.")
      end
    end

    @doc """
      Returns a status of current git repository
    """
    def status(data) do
      case System.cmd("git", ["status", "--short"]) do
        {"", 0}  -> :ok
        {msg, 0} -> {:changes, msg}
        {msg, e} -> {:error, {e, msg}}
      end
    end

    @doc """
      Adds a tag to the repo.
    """
    def tag!(data, tag) do
      case {System.cmd("git", ["tag", tag]), System.cmd("git", ["push", "--tags"])} do
        {{_, 0}, {_, 0}}  -> :ok
        other -> {:error, other}
      end
    end

    @doc """
      Commits to the repo.
    """
    def commit!(data, message) do
      case System.cmd("git", ["commit", "-am", message]) do
        {_, 0} ->
          System.cmd("git", "push")
          :ok
        other   -> {:error, other}
      end
    end
  end

  ##############################################################################
  # defp remote_repo_exists do
  #   {_, status} = System.cmd("git", ~W|help|)
  #   status == 0
  # end
  defp user_repo do
    case System.cmd("git", ~W|remote show origin|) do
      {answer, 0} ->
        [push_url] = Regex.run(~r|(?<=Push  URL: ).*|, answer)
        # [user, repo] =
        Regex.run(~r|([^/:]+)/([^/:]+$)|, push_url, capture: :all_but_first)
      {_error, _status} ->
        ["", ""]
    end
  end
end

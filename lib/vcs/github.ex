defmodule Issuer.Github do
  alias Issuer.CLI.IO.Ncurses, as: CLI
  alias Issuer.CLI.Question
  alias Issuer.CLI.Question.Input

  @client Tentacat.Client.new(%{access_token: Issuer.vcs[:token]})
  @user   to_string(Issuer.vcs[:user])
  @repo   to_string(Issuer.vcs[:repo])

  @moduledoc """
    1. Go to [`https://github.com/settings/tokens/new`](https://github.com/settings/tokens/new) and issue
       a new token to be used by your application.
  """
  defstruct user:   @user,
            repo:   @repo,
            client: @client

  def keys do
    Tentacat.Users.Keys.list(Issuer.vcs[:user], @client)
  end

  @doc """
    Asks the user for the token, suggest her to update `mix.exs` accordingly.
    https://github.com/settings/tokens
  """
  def welcome_setup do
    [user, repo] = user_repo()
    home = System.get_env("HOME")
    prv  = if File.exists?(Path.join([home, ".ssh", "id_rsa"])), do: Path.join([home, ".ssh", "id_rsa"]), else: Path.join([home, ".ssh", "???"])
    pub  = if File.exists?(Path.join([home, ".ssh", "id_rsa.pub"])), do: Path.join([home, ".ssh", "id_rsa.pub"]), else: Path.join([home, ".ssh", "???"])
    pem  = if File.exists?(Path.join([home, ".ssh", "id_rsa.pub.pem"])), do: Path.join([home, ".ssh", "id_rsa.pub.pem"]), else: "MISSING"

    notice = ~s"""


    =============================================================================================

                                    PLEASE READ THIS CAREFULLY

    —————————————————————————————————————————————————————————————————————————————————————————————
       You seem to not have a repository set up in your `mix.exs` file.

       Don’t worry, it’s more or less easy. Currently supported repositories a̶r̶e̶ is github only.
       Please go to https://github.com/settings/tokens and create a new token for me.
       You will be prompted to copy-paste it here to encrypt it to keep within your codebase.

       Also I will need a path to your RSA keys (`pem` is required to encrypt a token,
       `private` for decrypt it on the fly when needed, please read about it in google,
       or simply execute:

           $ \e[1mopenssl rsa -in ~/.ssh/id_rsa -pubout > ~/.ssh/id_rsa.pub.pem\e[0m

       in your shell if you trust me.) I will ask about the location of these keys as well.

       There could be a delay requesting for the current git repo and user, please stay patient
       after pressing <Enter> key below. It will take some time. Go grab a coffee. Anyway.
    —————————————————————————————————————————————————————————————————————————————————————————————

                PLEASE HAVE YOUR GITHUB TOKEN ON HAND, SINCE I HAVE A 1 MIN TIMEOUT

                                                 — Cordially, your ugly screaming console beast.

    =============================================================================================

    """
    IO.puts notice
    IO.gets "Press <Enter> to continue, or <Ctrl>+<C> to abort..."

    questions = [
      %Input{
        title: "Please enter the path to your PRIVATE key:", suggestion: prv
      } |> Question.to_question,
      %Input{
        title: "Please enter the path to your PUBLIC key:", suggestion: pub
      } |> Question.to_question,
      %Input{
        title: "Please enter the path to your PEM key:", suggestion: pem
      } |> Question.to_question,
      %Input{
        title: "Please enter your git user’s name:", suggestion: user
      } |> Question.to_question,
      %Input{
        title: "Please enter your projects’s name:", suggestion: repo
      } |> Question.to_question,
      %Input{
        title: "Please enter your token:"
      } |> Question.to_question
    ]
    [prv, pub, pem, user, repo, token] = CLI.survey! "Here you go:", questions

    can_encrypt = File.exists?(prv) && File.exists?(pem)

    unless can_encrypt do
      IO.puts ~s"""

      \e[31m=============================================================================================\e[0m
         \e[1;31mWARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!!\e[0m
      \e[31m—————————————————————————————————————————————————————————————————————————————————————————————\e[0m
         You have not specified proper RSA keys, encryption is impossible.
         The \e[1mtoken\e[0m can not be encrypted. I will print it here for you to write down.

         Please create the RSA keys, encrypt the token with:

             iex> \e[1mIssuer.Utils.encrypt("#{token}")\e[0m

        and put the result \e[1mas charlist\e[0m (in single quotes) to `mix.exs`.
      \e[31m=============================================================================================\e[0m

      """
    end

    token = if can_encrypt, do: Issuer.Utils.encrypt(token), else: "<REQUIRES RSA KEY TO ENCRYPT>"

    mix_section = ~s"""
    config :issuer, :identity, [
      prv: "#{prv}",
      pub: "#{pub}",
      pem: "#{pem}"
    ]

    config :issuer, :vcs, [
      engine: :github,
      user:   "#{user}",
      repo:   "#{repo}",
      token:  '#{token}'
    ]
    """

    IO.puts ~s"""
    \e[32m=============================================================================================\e[0m
      \e[1;32mPut the code below into your `mix.exs` file, and run this task again:\e[0m
    \e[32m—————————————————————————————————————————————————————————————————————————————————————————————\e[0m

    #{mix_section}
    \e[32m=============================================================================================\e[0m
    """
  end

  defimpl Issuer.Vcs, for: Issuer.Github do
    def tags(data) do
      Tentacat.Repositories.Tags.list(data.user, data.repo, data.client)
        |> Enum.map(fn e -> e["name"] end)
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

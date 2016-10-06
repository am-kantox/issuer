defmodule Issuer.Github do
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

  defimpl Issuer.Vcs, for: Issuer.Github do
    def diff(data, label \\ nil) do
    end

    def commit(data, message) do
    end

    def tag!(data, tag) do
    end

    def tags(data) do
      Tentacat.Repositories.Tags.list(data.user, data.repo, data.client)
        |> Enum.map(fn e -> e["name"] end)
    end

    def push(data) do
    end
  end
end

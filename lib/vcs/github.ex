defmodule Issuer.Github do
  @moduledoc """
    1. Go to [`https://github.com/settings/tokens/new`](https://github.com/settings/tokens/new) and issue
       a new token to be used by your application.
  """
  defstruct user:   Issuer.vcs[:user],
            repo:   Issuer.vcs[:repo]

  @client Tentacat.Client.new(%{access_token: Issuer.vcs[:token]})

  def keys(data) do
    @client |> Tentacat.Users.Keys.list_mine
  end

  defimpl Issuer.Vcs, for: Issuer.Github do
    def diff(data, label \\ nil) do
    end

    def commit(data, message) do
    end

    def tag!(data, tag) do
    end

    def tags(data) do
      @client |> Tentacat.Repositories.Tags.list data.user, data.repo
    end

    def push(data) do
    end
  end
end

defmodule Issuer do
  @moduledoc """
    https://groups.google.com/forum/?utm_medium=email&utm_source=footer#!msg/elixir-lang-core/MMB3ru8Rcxc/przYMxhZBAAJ

  """
  def main(opts \\ []) do
    # opts = config |> Keyword.merge(opts)
    config = settings(opts)
    IO.puts "Hello, world!. Options: #{inspect(opts)}"
  end

  def vcs do
    {_, data} = (Application.get_env(:issuer, :vcs) || [])
                  |> Enum.into(%{})
                  |> Map.get_and_update(:token, fn curr -> {curr, curr |> Issuer.Utils.decrypt} end)
    data
  end

  def setting(name) do
    settings[name]
  end

  ##############################################################################

  @settings [
    version: ["README"]
  ]

  defp settings(opts \\ [], persist \\ true) do
    cfg = @settings
          |> Keyword.merge(Application.get_env(:issuer, :settings) || [])
          |> Keyword.merge(opts)
    if persist, do: Mix.Config.persist(issuer: [settings: cfg])
    cfg
  end
end

Issuer.main

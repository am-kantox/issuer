defmodule Issuer do
  @moduledoc """
    https://groups.google.com/forum/?utm_medium=email&utm_source=footer#!msg/elixir-lang-core/MMB3ru8Rcxc/przYMxhZBAAJ

  """

  def vcs do
    {_, data} = (Application.get_env(:issuer, :vcs) || [])
                  |> Enum.into(%{})
                  |> Map.get_and_update(:token, fn curr -> {curr, curr |> Issuer.Utils.decrypt} end)
    data
  end

  ##############################################################################

  # defp settings(opts \\ [], persist \\ true) do
  #   cfg = (Application.get_env(:issuer, :settings) || [])
  #         |> Keyword.merge(opts)
  #   if persist, do: Mix.Config.persist(issuer: [settings: cfg])
  #   cfg
  # end
end

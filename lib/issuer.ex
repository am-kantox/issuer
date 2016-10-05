defmodule Issuer do
  @moduledoc """
  """
  def main(opts \\ []) do
    # opts = config |> Keyword.merge(opts)
    config = settings(opts)
    IO.puts "Hello, world!. Options: #{inspect(opts)}"
  end

  def token do
    Application.get_env(:issuer, :vcs)[:token] |> decrypt
  end

  def vcs do
    Application.get_env(:issuer, :vcs) || []
  end

  def setting(name) do
    settings[name]
  end

  ##############################################################################

	def encrypt(text) do
    [identity] = Application.get_env(:issuer, :identity)[:pem]
                   |> File.read!
                   |> :public_key.pem_decode
		text
      |> :public_key.encrypt_public(identity |> :public_key.pem_entry_decode)
      |> :base64.encode_to_string
	end

	def decrypt(text) do
    [identity] = Application.get_env(:issuer, :identity)[:prv]
                   |> File.read!
                   |> :public_key.pem_decode
		text
      |> :base64.decode
      |> :public_key.decrypt_private(identity |> :public_key.pem_entry_decode)
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

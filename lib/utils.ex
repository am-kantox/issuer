defmodule Issuer.Utils do

  ##############################################################################

  @doc """
  RSA-encrypts the text given. See
  [Encryption with RSA Key Pairs](http://krisjordan.com/essays/encrypting-with-rsa-key-pairs)
  for details. [More howtos](https://gist.github.com/colinstein/de1755d2d7fbe27a0f1e).
  Accepts binary as an input.

      iex> "Hello, world!" |> Issuer.Utils.encrypt |> Issuer.Utils.decrypt
      "Hello, world!"
  """
  def encrypt(text) do
    [identity] = Application.get_env(:issuer, :identity)[:pem]
                   |> File.read!
                   |> :public_key.pem_decode
    text
      |> :public_key.encrypt_public(identity |> :public_key.pem_entry_decode)
      |> :base64.encode_to_string
  end

  @doc """
  RSA-decrypts the text given. See
  [Encryption with RSA Key Pairs](http://krisjordan.com/essays/encrypting-with-rsa-key-pairs)
  for details. Accepts charlist as an input.
  """
  def decrypt(text) do
    [identity] = Application.get_env(:issuer, :identity)[:prv]
                   |> File.read!
                   |> :public_key.pem_decode
    text
      |> :base64.decode
      |> :public_key.decrypt_private(identity |> :public_key.pem_entry_decode)
  end

  ##############################################################################

  @version_file Path.join("config", "VERSION")
  @mix_file "mix.exs"
  @re ~r|version:\s*"([-.\w]+)"|
  @proper_mix_version ~S|version: File.read!(Path.join("config", "VERSION"))|

  @doc """
  Returns “sprouts” for VCS tags. Those might be the the next version tag.
  For instance, `["0.0.1"]` has these leaves:
  - `"0.0.2"`
  - `"0.0.2-dev"`
  - `"0.0.2-rc.1"`
  - `"0.1.0"`
  - `"0.1.0-dev"`
  - `"0.1.0-rc.1"`
  - `"1.0.0"`
  - `"1.0.0-dev"`
  - `"1.0.0-rc.1"`

      iex> Tentacat.Repositories.Tags.list("elixir-lang", "elixir")
      ...>   |> Enum.map(fn e -> e["name"] end)
      ...>   |> Issuer.Utils.sprouts
      [ "v1.3.4", "v1.3.4-dev", "v1.3.4-rc.1", "v1.4.0", "v1.4.0-dev", "v1.4.0-rc.1", "v2.0.0", "v2.0.0-dev", "v2.0.0-rc.1" ]
  """
  # ["v1.3.3", "v1.3.2", "v1.3.1", "v1.3.0", "v1.3.0-rc.1", "v1.3.0-rc.0", "v1.2.6",
  #  "v1.2.5", "v1.2.4", "v1.2.3", "v1.2.2", "v1.2.1", "v1.2.0", "v1.2.0-rc.1",
  #  "v1.2.0-rc.0", "v1.1.1", "v1.1.0", "v1.1.0-rc.0", "v1.0.5", "v1.0.4", "v1.0.3",
  #  "v1.0.2", "v1.0.1", "v1.0.0", "v1.0.0-rc2", "v1.0.0-rc1", "v0.15.1", "v0.15.0",
  #  "v0.14.3", "v0.14.2", "v0.14.1", "v0.14.0", "v0.13.3", "v0.13.2", "v0.13.1",
  #  "v0.13.0", "v0.12.5", "v0.12.4", "v0.12.3", "v0.12.2", "v0.12.1", "v0.12.0",
  #  "v0.11.2", "v0.11.1", "v0.11.0", "v0.10.3", "v0.10.2", "v0.10.1", "v0.10.0",
  #  "v0.9.3", ...]
  # ⇓⇓⇓
  # [["v", "1", "3", "3", "", ""], ..., ["v", "1", "0", "0", "-rc", "2"]]
  def sprouts([]), do: [version?]
  def sprouts(tags) do
  end


  ##############################################################################

  @doc """
  Returns “sprouts” for VCS tags. Those might be the the next version tag.
  For instance, current elixir git repo has these leaves:
  - `"v0.15.1"`
  - `"v1.3.3"`
  - `"v1.4.0-rc.1"`

      iex> tags = ["v1.4.0-rc.1", "v1.4.0-dev",
      ...> "v1.3.3", "v1.3.2", "v1.3.1", "v1.3.0", "v1.3.0-rc.1", "v1.3.0-rc.0", "v1.2.6",
      ...> "v1.2.5", "v1.2.4", "v1.2.3", "v1.2.2", "v1.2.1", "v1.2.0", "v1.2.0-rc.1",
      ...> "v1.2.0-rc.0", "v1.1.1", "v1.1.0", "v1.1.0-rc.0", "v1.0.5", "v1.0.4", "v1.0.3",
      ...> "v1.0.2", "v1.0.1", "v1.0.0", "v1.0.0-rc2", "v1.0.0-rc1", "v0.15.1", "v0.15.0",
      ...> "v0.14.3", "v0.14.2", "v0.14.1", "v0.14.0", "v0.13.3", "v0.13.2", "v0.13.1",
      ...> "v0.13.0", "v0.12.5", "v0.12.4", "v0.12.3", "v0.12.2", "v0.12.1", "v0.12.0",
      ...> "v0.11.2", "v0.11.1", "v0.11.0", "v0.10.3", "v0.10.2", "v0.10.1", "v0.10.0",
      ...> "v0.9.3"]
      ...> tags |> Issuer.Utils.leaves
      ["v1.4.0-rc.1", "v1.3.3", "v0.15.1"]
  """
  def leaves(tags) do
    tops = tags
             |> Enum.map(&Regex.run(~r/\A(\D*)(\d+)\.(\d+)\.(\d+)(.*)?\z/, &1, capture: :all_but_first))
             |> Enum.map(fn [prefix, h, m, s, suffix] ->
                   [prefix, String.to_integer(h), String.to_integer(m), String.to_integer(s), suffix]
                end)
    tops
             |> Enum.reject(fn [prefix, h, m, s, suffix] ->
                   # { |e| inp1.any? { |i| i != e && i[1] == e[1]
                   #                              && (i[2] > e[2] || i[2] == e[2] && i[3] > e[3]) && i[4].empty?
                   #                              || (i[2] == e[2] && i[3] == e[3] && i[4] > e[4])  } }
                  tops
                    |> Enum.any?(fn [px, hh, mm, ss, sx] ->
                         [prefix, h, m, s, suffix] != [px, hh, mm, ss, sx] && hh == h &&
                             ((mm > m || mm == m && ss > s) && sx == "" || mm == m && ss == s && sx > suffix)
                       end)
                 end)
             |> Enum.map(fn [prefix, h, m, s, suffix] ->
                   "#{prefix}#{h}.#{m}.#{s}#{suffix}"
                 end)
  end

  defp version?(v \\ "0.0.1") do
    mix = File.read!(@mix_file)
    # version: "0.1.0" ⇒ version: File.read!("VERSION")
    case Regex.scan(@re, mix, capture: :all_but_first) |> List.flatten do
      [content] when is_binary(content) -> # found a version as is in mix :(
        File.write!(@version_file, content)
        File.write!(@mix_file, Regex.replace(@re, mix, @proper_mix_version))
        {:mix!, content}
      _ ->
        case File.read(@version_file) do
          {:error, :enoent} ->
            File.write!(@version_file, v)
            {:version!, v}
          {:ok, content} -> {:ok, content |> String.trim}
        end
    end
  end

  defp version!(v \\ "0.0.1") do
    {status, _} = version?(v)
    File.write(@version_file, v)
    {status, v}
  end
end

defmodule Issuer.Utils do

  @version_file Path.join("config", "VERSION")
  @interfaces_file Path.join("config", "INTERFACES")
  @mix_file "mix.exs"
  @re ~r|version:\s*"([-.\w]+)"|
  @proper_mix_version ~S|version: File.read!(Path.join("config", "VERSION"))|

  @doc """
  Returns “sprouts” for VCS tags. Those might be the the next version tag.

      iex> ["0.0.1"] |> Issuer.Utils.sprouts
      ["0.0.2", "0.1.0", "0.1.0-dev", "0.1.0-rc.1", "1.0.0", "1.0.0-dev", "1.0.0-rc.1"]

      iex> ["0.1.1-rc2"] |> Issuer.Utils.sprouts
      ["0.1.1", "0.1.1-rc3"]

      iex> tags = ["v1.4.0-rc.1", "v1.4.0-dev",
      ...> "v1.3.3", "v1.3.2", "v1.3.1", "v1.3.0", "v1.3.0-rc.1", "v1.3.0-rc.0", "v1.2.6",
      ...> "v1.2.5", "v1.2.4", "v1.2.3", "v1.2.2", "v1.2.1", "v1.2.0", "v1.2.0-rc.1",
      ...> "v1.2.0-rc.0", "v1.1.1", "v1.1.0", "v1.1.0-rc.0", "v1.0.5", "v1.0.4", "v1.0.3",
      ...> "v1.0.2", "v1.0.1", "v1.0.0", "v1.0.0-rc2", "v1.0.0-rc1", "v0.15.1", "v0.15.0",
      ...> "v0.14.3", "v0.14.2", "v0.14.1", "v0.14.0", "v0.13.3", "v0.13.2", "v0.13.1",
      ...> "v0.13.0", "v0.12.5", "v0.12.4", "v0.12.3", "v0.12.2", "v0.12.1", "v0.12.0",
      ...> "v0.11.2", "v0.11.1", "v0.11.0", "v0.10.3", "v0.10.2", "v0.10.1", "v0.10.0",
      ...> "v0.9.3"]
      ...> tags |> Issuer.Utils.sprouts
      ["v1.4.0", "v1.4.0-rc.2", "v1.3.4", "v2.0.0", "v0.15.2", "v0.16.0", "v1.0.0"]
  """
  def sprouts(tags) when is_list(tags) do
    [head | tail] = tags |> leaves |> Enum.map(&sprouts/1)
    [head | tail |> Enum.map(fn e -> e |> Enum.reject(&suffixed?/1) end)]
      |> List.flatten
      |> Enum.uniq
#      |> Enum.sort(&(&1 > &2)) # FIXME appropriate sorting?
  end
  def sprouts(tags) when is_binary(tags) do
    tags |> version |> smart_sprouts
  end

  ##############################################################################

  @doc """
  Returns “leaves” for VCS tags. Those might be the the next version tag.
  For instance, current elixir git repo has these leaves:
  - `"v0.15.1"`
  - `"v1.3.3"`
  - `"v1.4.0-rc.1"`

  The function will filter out all the existing tags to these:

      iex> Issuer.Utils.leaves([]) |> Enum.count
      1

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
  def leaves([]) do
    {_, version} = version?()
    [version]
  end
  def leaves(tags) do
    tops = tags |> Enum.map(&version/1)
    tops
      |> Enum.reject(fn [the_prefix, the_h, the_m, the_s, the_suffix] ->
           tops
             |> Enum.any?(fn [a_prefix, a_h, a_m, a_s, a_suffix] ->
                  [the_prefix, the_h, the_m, the_s, the_suffix] != [a_prefix, a_h, a_m, a_s, a_suffix] &&
                    the_h == a_h &&
                    (
                      (a_m > the_m || a_m == the_m && a_s > the_s) && a_suffix == "" ||
                      a_m == the_m && a_s == the_s && a_suffix > the_suffix
                    )
                end)
         end)
      |> Enum.sort(&compare_versions/2)
      |> Enum.map(&version/1)
  end

  ##############################################################################

  def interface_changes?(neu \\ Issuer.Utils.functions!) do
    case File.read(@interfaces_file) do
      {:error, :enoent} -> {:not_found, {:+, neu}, {:-, []}}
      {:ok, legacy} ->
        {legacy, _} = legacy |> Code.eval_string
        {:found, {:+, subtract_keywords(neu, legacy)}, {:-, subtract_keywords(legacy, neu)}}
    end
  end
  def interface_changes! do
    neu = Issuer.Utils.functions!
    result = neu |> interface_changes?
    File.write(@interfaces_file, Macro.to_string(neu))
    result
  end

  defp subtract_keywords(l1, l2) do
    l1 |> Keyword.drop(l2 |> Keyword.keys)
  end

  @doc """

  ## Examples

      iex> with {name, _} <- Issuer.Utils.functions! |> List.last, do: name
      :"Mix.Tasks.Issuer.Version#run/1"
  """
  def functions! do
    unless loaded?(), do: Mix.raise("Project structure is not loaded, aborting. Please revise manually.")

    modules!()
    |> Enum.reduce([], fn mod, acc -> acc |> Keyword.merge(docs(mod)) end)
    # |> Enum.sort_by(fn {k, _} -> k end)
  end

  @doc """

  ## Examples

      iex> Issuer.Utils.modules! |> List.last
      Mix.Tasks.Issuer.Version
  """
  def modules!, do: with {:ok, list} <- modules(), do: list, else: []

  defp project do
    Mix.Project.get
    |> Module.split
    |> List.first
    |> String.downcase
    |> String.to_atom
  end

  defp loaded, do: :ets.match(:ac_tab, {{:loaded, :"$1"}, :_})

  defp loaded?(project \\ [project()]), do: loaded() |> Enum.find(& &1 == project)

  defp modules, do: :application.get_key(project(), :modules)

  defp docs(module) do
    module_name = "#{module}"
                  |> String.trim_leading("Elixir.")
    module
    |> Code.get_docs(:docs) # {{:commit!, 1}, 92, :def, [{:argv, [], nil}], nil}
    |> Enum.filter(fn {{name, _}, _, _, _, _} ->
         not (name |> Atom.to_string |> String.starts_with?("__"))
       end)
    |> Enum.reduce([], fn {{name, arity}, line, _kw, _args, doc}, acc ->
         acc |> put_in(["#{module_name}##{name}/#{arity}" |> String.to_atom], {line, doc})
       end)
  end

  ##############################################################################

  def version!(v) when is_binary(v) do
    case version_valid?(v) do
      false -> {:invalid, v}
      version ->
        uv = version |> unprefix_version
        File.write(@version_file, uv)

        # ⇓ FIXME HACK to hot update version
        cfg = Mix.ProjectStack.pop |> update_in([:config, :version], fn _ -> uv end)
        Mix.ProjectStack.push cfg[:name], cfg[:config], cfg[:file]
        # ⇑ FIXME HACK to update version

        {:ok, version}
    end
  end

  def version?(v \\ "0.0.1") do
    # version: "0.1.0" ⇒ version: File.read!("VERSION")
    case version_in_mix?(true) do
      {:yes, version} -> # found a version as is in mix :(
        File.write!(@version_file, version)
        File.write!(@mix_file, Regex.replace(@re, File.read!(@mix_file), @proper_mix_version))
        {:mix!, version}
      {:no, :ok} ->
        case File.read(@version_file) do
          {:error, :enoent} ->
            File.write!(@version_file, v)
            {:version!, v}
          {:ok, version} -> {:ok, version |> String.trim}
        end
      {:no, _} ->
        Mix.raise("Found many version strings in `mix`, aborting. Please revise manually.")
    end
  end

  ##############################################################################

  def prefix_version(v) when is_binary(v) do
    prefix_version(version(v))
  end
  def prefix_version(["", h, m, s, suffix]) do
    version(["v", h, m, s, suffix])
  end
  def prefix_version([prefix, h, m, s, suffix]) do
    version([prefix, h, m, s, suffix])
  end

  def unprefix_version(v) when is_binary(v) do
    unprefix_version(version(v))
  end
  def unprefix_version([_prefix | tail]) do
    version(["" | tail])
  end

  def version_valid?(v) do
    try do
      version(v)
    rescue
      MatchError -> false
    end
  end

  ##############################################################################

  def version_in_mix?(_ \\ false)
  def version_in_mix?(false) do
    case version_in_mix?(true) do
      {_, :ok} -> false
      response -> response
    end
  end
  def version_in_mix?(true) do
    mix = File.read!(@mix_file)
    case Regex.scan(@re, mix, capture: :all_but_first) |> List.flatten do
      [version] when is_binary(version) -> {:yes, version}
      []                                -> {:no, :ok}
      multi                             -> {:no, multi}
    end
  end

  ##############################################################################

  # returns `["v", 0, 1, 3, "-dev"]`
  defp version(v) when is_binary(v) do
    [prefix, h, m, s, suffix] = Regex.run(~r/\A(\D*)(\d+)\.(\d+)\.(\d+)(.*)?\z/, v, capture: :all_but_first)
    [prefix, String.to_integer(h), String.to_integer(m), String.to_integer(s), suffix]
  end
  # returns `"v0.1.3-dev"`
  defp version([prefix, h, m, s, suffix]) do
    "#{prefix}#{h}.#{m}.#{s}#{suffix}"
  end
  # returns `"v0.1.3-dev"`
  defp compare_versions([_, the_h, the_m, the_s, the_sx], [_, a_h, a_m, a_s, a_sx]) do
    cond do
      the_h > a_h  -> true
      the_h < a_h  -> false
      the_m > a_m  -> true
      the_m < a_m  -> false
      the_s > a_s  -> true
      the_s < a_s  -> false
      the_sx == "" -> true
      a_sx == ""   -> false
      true         -> the_sx > a_sx
    end
  end

  defp suffixed?(v) when is_binary(v) do
    suffixed?(version(v))
  end
  defp suffixed?([_prefix, _h, _m, _s, suffix]) do
    suffix != ""
  end

  ##############################################################################

  # iex> ["0.0.1"] |> Issuer.Utils.sprouts
  # ["0.0.2", "0.1.0", "0.1.0-dev", "0.1.0-rc.1", "1.0.0", "1.0.0-dev", "1.0.0-rc.1"]
  defp smart_sprouts([prefix, h, m, s, ""]) do
    [
      version([prefix, h, m, s + 1, ""]),
      version([prefix, h, m + 1, 0, ""]),
      version([prefix, h, m + 1, 0, "-dev"]),
      version([prefix, h, m + 1, 0, "-rc.1"]),
      version([prefix, h + 1, 0, 0, ""]),
      version([prefix, h + 1, 0, 0, "-dev"]),
      version([prefix, h + 1, 0, 0, "-rc.1"]),
    ]
  end
  defp smart_sprouts([prefix, h, m, s, suffix]) do
    [version([prefix, h, m, s, ""]), version([prefix, h, m, s, inc_suffix(suffix)])]
  end
  defp inc_suffix(suffix) when is_binary(suffix) do
    Regex.replace(
      ~r|(rc.?)(\d+)|,
      String.replace(suffix, "dev", "rc.0"),
      fn _, f, s -> "#{f}#{String.to_integer(s) + 1}" end
    )
  end
end

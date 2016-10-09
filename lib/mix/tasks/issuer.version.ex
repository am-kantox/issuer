defmodule Mix.Tasks.Issuer.Version do
  use Mix.Task

  @shortdoc  "Fixes `mix.exs` for Issuer, putting verion into VERSION file"
  @moduledoc @shortdoc

  @doc false
  def run(opts \\ []) do
    case opts do
      [] -> case Issuer.Utils.version? do
              {:version!, version} ->
                flagged(true,  "Misconfiguration detected: version was not found. `VERSION` file was written.")
                version
              {:mix!, version} ->
                flagged(false, "Version updated in both `mix.exs` and `VERSION` files")
                version
              {:ok, version} -> version
            end
            :ok
      [version] when is_binary(version) ->
        {_, version} = Issuer.Utils.version?(version)
        Issuer.Utils.version!(version)
    end
  end

  ##############################################################################

  @notice ~s"""


  =============================================================================================

                                  PLEASE READ THIS CAREFULLY

  —————————————————————————————————————————————————————————————————————————————————————————————
     You seem to run this tool for the first time and/or after tweaking `mix.exs` file.

     Don’t worry, it’s more or less easy. I will update your `mix.exs` file
     to load the version from \e[1m`config/VERSION`\e[0m file. That simple.

     Currently supported repositories a̶r̶e̶ is github only.

     There could be a delay requesting for the current git repo’s info, please stay patient
     after pressing <Enter> key below. It will take some time. Go grab a coffee. Anyway.
  —————————————————————————————————————————————————————————————————————————————————————————————

                                               — Cordially, your ugly screaming console beast.

  =============================================================================================

  """
  defp notice do
    IO.puts notice
    IO.gets "Press <Enter> to continue, or <Ctrl>+<C> to abort..."
  end

  defp flagged(bold, text) do
    Bunt.puts [:bright, :red, (if bold, do: "​⚑", else: "⚐"), :reset, " ", text]
  end
end

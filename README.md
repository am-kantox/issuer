# Issuer

[![Build Status](https://travis-ci.org/am-kantox/issuer.svg?branch=master)](https://travis-ci.org/am-kantox/issuer)

```elixir
{:ok, app |> version_bump |> git_tag_commit_push |> hex publish} = `mix issuer`
```

## Installation

**TODO:** http://elixir-lang.org/docs/stable/mix/Mix.Project.html#in_project/4

```
iex> :code.all_loaded |> Enum.each(fn(t) -> if Regex.match?(~r|Mixfile|, Atom.to_string(elem(t, 0))), do: IO.inspect(t) end)
{ExNcurses.Mixfile, :in_memory}
{Issuer.Mixfile, :in_memory}
:ok

iex> :ets.match(:ac_tab, {{:loaded, :"$1"}, :_})
[[:iex], [:stdlib], [:bunt], [:ssl], [:compiler], [:asn1], [:hex], [:elixir],
 [:crypto], [:public_key], [:inets], [:issuer], [:logger], [:kernel], [:mix]]

iex> {:ok, list} = :application.get_key(:issuer, :modules)
{:ok,
 [Issuer, Issuer.CLI.IO.Gets, Issuer.CLI.IO.Ncurses, Issuer.CLI.Question,
  Issuer.CLI.Question.Input, Issuer.CLI.Question.Issuer.CLI.Question.Input,
  Issuer.CLI.Question.Issuer.CLI.Question.Variant,
  Issuer.CLI.Question.Issuer.CLI.Question.Variants,
  Issuer.CLI.Question.Issuer.CLI.Question.YesNo, Issuer.CLI.Question.Variant,
  Issuer.CLI.Question.Variants, Issuer.CLI.Question.YesNo, Issuer.Git,
  Issuer.Survey, Issuer.Survey.Issuer.CLI.IO.Gets,
  Issuer.Survey.Issuer.CLI.IO.Ncurses, Issuer.Utils, Issuer.Vcs,
  Issuer.Vcs.Issuer.Git, Mix.Tasks.Issuer, Mix.Tasks.Issuer.Version]}

iex> list |> Enum.map(fn mod -> {mod, mod.__info__(:functions) |> Enum.filter(fn {k, v} -> not String.starts_with?(Atom.to_string(k), "__") end)} end)


```

Add `issuer` to your list of dependencies in `mix.exs`:


```elixir
def deps do
  [{:issuer, "~> 0.1.2", only: :dev}]
end
```

## Usage

Run `mix issuer` to automate subsequent running of:

    mix test && \
      confirm_suggested_version && \           # ⇐ will load versions, suggest the succ and ask about
      patch_version_in_VERSION_and_README && \ # ⇐ will [safely] replace version to current in files
      git commit -am ":paperclip: Bump version." && \
      git push && \
      git tag VERSION_CHOSEN_IN_STEP_2 && \
      git push --tags && \
      hex publish

**NB**: on the first run it will move the version declaration out of `mix.exs`
to `config/VERSION`. I am not very proud of this solution, but I found it better
than modifying `mix.exs` on each subsequent run.

## FAQ

**Q:** Is it of any good?  
**A:** Yes, it is.

**Q:** Is `issuer` itself being published with `issuer`?  
**A:** Indeed.

**Q:** Won’t it ruin my project?  
**A:** Well, it could, but you have the project source versioned, haven’t you?

**Q:** What happens if any step failed?  
**A:** It’s `Elixir`, we just let the castle crash. `hex publish` is executed
if and only all previous steps succeeded.

## How it looks like:

![Screenshot](https://raw.githubusercontent.com/am-kantox/issuer/master/img/screenshot.png)

## Eastern Egg

Add:

```elixir
def deps do
  [{:ex_ncurses, git: "https://github.com/jfreeze/ex_ncurses.git", only: :dev}]
end
```

to your project’s `mix.exs` to be asked about version in fancy `ncurses`-based colorful manner :)

## Docs

[https://hexdocs.pm/issuer](https://hexdocs.pm/issuer)

## License

**MIT**

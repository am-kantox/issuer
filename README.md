# Issuer

```elixir
{:ok, app |> version_bump |> git_tag_commit_push |> hex publish} = `mix issuer`
```

## Installation

Add `issuer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:issuer, "~> 0.0.26", only: :dev}]
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

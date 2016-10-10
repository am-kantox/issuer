defmodule Issuer.CLI.IO.Gets do
  @title_color  36
  # @chosen_color 32

  defstruct title: "Hello, please answer our survey:",
            questions: []

  defimpl Issuer.Survey, for: Issuer.CLI.IO.Gets do
    def survey!(data) do
      IO.puts "\e[#{@title_color};1m#{data.title}\e[0m\n"
      data.questions |> Enum.map(&Issuer.CLI.IO.Gets.ask/1)
    end
  end

  ##############################################################################

  # plain text input
  def ask({title, choices, _chosen, position}) when is_binary(choices) do
    IO.gets "\e[#{@title_color}m#{title}\e[0m > "
  end

  # multi choice
  def ask({title, choices, chosen, position}) when is_list(choices) and is_list(chosen) do
    IO.puts "\e[#{@title_color}m#{title}\e[0m"
    choices |> Enum.with_index |> Enum.each(fn {line, i} ->
      Bunt.puts [:bright, "[#{i}]", :reset, " #{line}"]
    end)
    result = IO.gets "Comma-separated list: > "
    try do
      indices = result |> String.split(",") |> Enum.map(fn e -> e |> String.trim |> String.to_integer end)
      if indices |> Enum.all?(fn e -> choices |> Enum.at(e) end), do: indices, else: ask({title, choices, chosen, position})
      indices
    rescue
      [FunctionClauseError, ArgumentError] -> ask({title, choices, chosen, position})
    end
  end

  # single choice
  def ask({title, choices, chosen, position}) when is_list(choices) and is_integer(chosen) do
    IO.puts "\e[#{@title_color}m#{title}\e[0m"
    choices |> Enum.with_index |> Enum.each(fn {line, i} ->
      Bunt.puts [:bright, "[#{i}]", :reset, " #{line}"]
    end)
    result = IO.gets "Single index: > "
    try do
      index = result |> String.trim |> String.to_integer
      if choices |> Enum.at(index), do: index, else: ask({title, choices, chosen, position})
      index
    rescue
      [FunctionClauseError, ArgumentError] -> ask({title, choices, chosen, position})
    end
  end

  ##############################################################################

  def size(choices) when is_list(choices), do: Enum.count(choices)
  def size(choices) when is_binary(choices), do: 1

end

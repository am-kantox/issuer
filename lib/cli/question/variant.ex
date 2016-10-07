defmodule Issuer.CLI.Question.Variant do
  @title "Please select one variant:"
  @choices ["Bill Gates", "Linux Torvalds", "Steve Jobs"]
  @chosen -1
  @position 0

  defstruct title: @title,
            choices: @choices,
            choice: @chosen,
            position: @position

  defimpl Issuer.CLI.Question, for: Issuer.CLI.Question.Variant do
    def to_question(data, _opts \\ []) do
      { data.title, data.choices, data.choice, data.position }
    end
  end
end

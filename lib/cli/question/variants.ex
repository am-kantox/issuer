defmodule Issuer.CLI.Question.Variants do
  @title "Please select one or many variants:"
  @choices ["Bill Gates", "Linux Torvalds", "Steve Jobs"]
  @chosen [1, 2]
  @position 0

  defstruct title: @title,
            choices: @choices,
            choice: @chosen,
            position: @position

  defimpl Issuer.CLI.Question, for: Issuer.CLI.Question.Variants do
    def to_question(data, opts \\ []) do
      { data.title, data.choices, data.choice, data.position }
    end
  end
end

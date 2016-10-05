defmodule Issuer.CLI.Question.Input do
  @title "Please select one proper person:"
  @choices ""
  @chosen 0
  @position 0

  defstruct title: @title,
            choices: @choices,
            choice: @chosen,
            position: @position

  defimpl Issuer.CLI.Question, for: Issuer.CLI.Question.Input do
    def to_question(data, opts \\ []) do
      { data.title, data.choices, data.choice, data.position }
    end
  end
end

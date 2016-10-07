defmodule Issuer.CLI.Question.Input do
  @title "Please enter your variant:"
  @suggestion ""
  @chosen ""
  @position -1

  defstruct title: @title,
            suggestion: @suggestion,
            choice: @chosen,
            position: @position

  defimpl Issuer.CLI.Question, for: Issuer.CLI.Question.Input do
    def to_question(data, _opts \\ []) do
      position = if data.position >= 0, do: data.position, else: String.length(data.suggestion)
      { data.title, data.suggestion, data.choice, position }
    end
  end
end

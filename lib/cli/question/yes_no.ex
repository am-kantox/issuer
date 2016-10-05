defmodule Issuer.CLI.Question.YesNo do
  defstruct title: nil,
            default: :yes

  @default :yes

  defimpl Issuer.CLI.Question, for: Issuer.CLI.Question.YesNo do
    def to_question(data, opts \\ []) do
      { data.title, ["Yes", "No"], 0 } # FIXME I18N
    end
  end
end

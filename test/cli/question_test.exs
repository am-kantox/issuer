if System.get_env("ISSUER_INTERACTIVE_TEST") == "true" do

  defmodule Issuer.CLI.Question.Test do
    use ExUnit.Case
    require Logger
    import ExUnit.CaptureLog
    doctest Issuer.CLI.Question.YesNo

    alias Issuer.CLI.IO.Ncurses

#    test "ask for different answers" do
#      q = [
#        %Issuer.CLI.Question.Variant{} |> Issuer.CLI.Question.to_question,
#        %Issuer.CLI.Question.Variants{} |> Issuer.CLI.Question.to_question,
#        %Issuer.CLI.Question.Input{} |> Issuer.CLI.Question.to_question
#      ]
#      questions = (for i <- 1..2, do: q) |> Enum.flat_map(fn e -> e end) |> Enum.shuffle
#      Ncurses.survey! "Hello, please answer our survey:", questions
#    end

    test "ask for repo details" do
      Issuer.Github.encrypt_token
    end
  end

end

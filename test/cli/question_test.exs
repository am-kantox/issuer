if System.get_env("ISSUER_INTERACTIVE_TEST") == "true" do

  defmodule Issuer.CLI.Question.Test do
    use ExUnit.Case
    require Logger
    import ExUnit.CaptureLog

    alias Issuer.CLI.Question

    test "ask for different answers (ncurses)" do
      %Issuer.CLI.IO.Ncurses{title: "Hello, please answer our survey:", questions: questions()}
        |> Issuer.Survey.survey!
    end

    test "ask for different answers (plain gets)" do
      %Issuer.CLI.IO.Gets{title: "Hello, please answer our survey:", questions: questions()}
        |> Issuer.Survey.survey!
    end

    ############################################################################

    defp questions do
      q = [
        %Question.Variant{} |> Question.to_question,
        %Question.Variants{} |> Question.to_question,
        %Question.Input{} |> Question.to_question
      ]
      (for i <- 1..2, do: q) |> Enum.flat_map(&(&1)) |> Enum.shuffle
    end
  end

end

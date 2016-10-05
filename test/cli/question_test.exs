defmodule Issuer.CLI.Question.Variant.Test do
  use ExUnit.Case
  require Logger
  import ExUnit.CaptureLog
  doctest Issuer.CLI.Question.YesNo

  alias Issuer.CLI.IO.Ncurses

  test "ask for variant answer" do
    q = %Issuer.CLI.Question.Variant{} |> Issuer.CLI.Question.to_question
    questions = for i <- 1..10, do: q
    Ncurses.survey! "Hello, please answer:", questions
    # assert capture_log(fn ->
    #   %Question.YesNo{title: "How do you do?"} |> Question.ask
    # end) =~ "How do you do?"
  end

  test "ask for variants answer" do
    q = %Issuer.CLI.Question.Variants{} |> Issuer.CLI.Question.to_question
    questions = for i <- 1..10, do: q
    Ncurses.survey! "Hello, please answer:", questions
    # assert capture_log(fn ->
    #   %Question.YesNo{title: "How do you do?"} |> Question.ask
    # end) =~ "How do you do?"
  end

  test "ask for the answer to input" do
    q = %Issuer.CLI.Question.Input{} |> Issuer.CLI.Question.to_question
    Ncurses.survey! "Hello, please answer:", [q]
    # assert capture_log(fn ->
    #   %Question.YesNo{title: "How do you do?"} |> Question.ask
    # end) =~ "How do you do?"
  end
end

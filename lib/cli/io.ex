defmodule Issuer.CLI.IO.Ncurses do
  @title_color  36
  @chosen_color 32

  @chosen_many_no "☐"
  @chosen_many_yes "☑"
  @chosen_one_no "◎"
  @chosen_one_yes "🔘" # ● ◉ ⬤ 🔘

  # FIXME Currently we have to pass the title that fits on the line
  #        to properly render a caption, which is ugly.
  #       Need to calculate it!
  def survey!(title, questions, row \\ 0) when is_list(questions) do
    ExNcurses.n_begin()
    refresh(false)

    IO.puts "\e[#{row};0H\e[#{@title_color};1m#{title}\e[0m\n"
    {results, _} = questions |> Enum.map_reduce(row + 3, fn {title, choices, chosen, position}, acc ->
      # FIXME store the whole screen text in the string array and print everything
      rows = ExNcurses.lines()
      choice_size = size(choices) + 2
      left = (acc + choice_size) - rows
      if left > 0, do: (1..left) |> Enum.each(fn _ -> IO.puts("\e[#{rows};0H") end) # scroll it
      acc = Enum.min [acc, ExNcurses.lines() - choice_size]
      {ask(acc, {title, choices, chosen, position}), acc + choice_size}
    end)
    refresh(true)
    ExNcurses.clear()
    ExNcurses.n_end()

    results
  end

  def ask(question) do
    question |> IO.ANSI.format

  end

  ##############################################################################

  defp ask(row, questionnaire, final \\ false)

  # multi choice
  defp ask(row, {title, choices, _chosen, position}, final) when is_binary(choices) do
    refresh(false)

    IO.puts "\e[#{row};0H\e[#{@title_color}m#{title}\e[0m"
    IO.puts "\e[#{row + 1};0H\e[2K\e[#{prefix(final)}m#{choices}\e[0m"

    upwards = row
    len = String.length(choices)
    IO.puts "\e[#{upwards};#{position + 1}H"

    unless final do
      ExNcurses.keypad() # clear input
      ExNcurses.flushinp() # clear input
      case ExNcurses.getchar() do # FIXME support arrows, everything is prepared, see position
        8   -> ask(row, {title, delete_last_grapheme(choices), 0, [position - 1, 0] |> Enum.max})
        263 -> ask(row, {title, delete_last_grapheme(choices), 0, [position - 1, 0] |> Enum.max})
        330 -> ask(row, {title, delete_last_grapheme(choices), 0, [position - 1, 0] |> Enum.max})
        10  ->
          if len > 0 do
            ask(row, {title, choices, 0, len}, true)
            choices
          else
            ask(row, {title, choices, 0, len})
          end
        any -> ask(row, {title, choices <> <<any>>, 0, position + 1})
      end
    end
  end

  # multi choice
  defp ask(row, {title, choices, chosen, position}, final) when is_list(choices) and is_list(chosen) do
    refresh(false)

    IO.puts "\e[#{row};0H\e[#{@title_color}m#{title}\e[0m"
    choices |> Enum.with_index |> Enum.each(fn {line, i} ->
      IO.puts "\e[#{row + i + 1};0H#{checkbox({i, chosen}, final)} #{line}\e[0m"
    end)

    choice_count = Enum.count(choices)
    upwards = row + 2 - choice_count + position + 1
    IO.puts "\e[#{upwards};0H"

    unless final do
      ExNcurses.keypad() # clear input
      ExNcurses.flushinp() # clear input
      case ExNcurses.getchar() do
        258 -> ask(row, {title, choices, chosen, rem(position + 1, choice_count)})
        259 -> ask(row, {title, choices, chosen, rem(position + choice_count - 1, choice_count)})
        260 -> ask(row, {title, choices, chosen, 0})
        261 -> ask(row, {title, choices, chosen, choice_count - 1})
        32  ->
          chosen = if chosen |> Enum.any?(fn e -> e == position end) do
                     chosen |> Enum.reject(fn e -> e == position end)
                   else
                     chosen ++ [position]
                   end
          ask(row, {title, choices, chosen, position})
        10  ->
          ask(row, {title, choices, chosen, position}, true)
          chosen
        _ -> ask(row, {title, choices, chosen, position})
      end
    end
  end

  # single choice
  defp ask(row, {title, choices, chosen, position}, final) when is_list(choices) and is_integer(chosen) do
    refresh(false)

    IO.puts "\e[#{row};0H\e[#{@title_color}m#{title}\e[0m"
    choices |> Enum.with_index |> Enum.each(fn {line, i} ->
      IO.puts "\e[#{row + i + 1};0H#{bullet(i == chosen, final)} #{line}\e[0m"
    end)

    choice_count = Enum.count(choices)
    upwards = row + 2 - choice_count + position + 1
    IO.puts "\e[#{upwards};0H"

    unless final do
      ExNcurses.keypad() # clear input
      ExNcurses.flushinp() # clear input
      case ExNcurses.getchar() do
        258 -> ask(row, {title, choices, rem(position + 1, choice_count), rem(position + 1, choice_count)})
        259 -> ask(row, {title, choices, rem(position + choice_count - 1, choice_count), rem(position + choice_count - 1, choice_count)})
        260 -> ask(row, {title, choices, 0, 0})
        261 -> ask(row, {title, choices, choice_count - 1, choice_count - 1})
        32  -> ask(row, {title, choices, position, position})
        10  ->
          ask(row, {title, choices, position, position}, true)
          position
        _ -> ask(row, {title, choices, chosen, position})
      end
    end
  end

  ##############################################################################

  defp refresh(clear?) do
    ExNcurses.mvprintw(0, 0, "")
    ExNcurses.refresh()
    if clear?, do: ExNcurses.clear()
  end

  defp prefix(false), do: "1"
  defp prefix(true), do: "32;1"

  defp bullet(false, _), do: "\e[0m#{@chosen_one_no} "
  defp bullet(true, final), do: "\e[#{prefix(final)}m#{@chosen_one_yes} "

  defp checkbox({i, all}, final) do
    checkbox(Enum.any?(all, fn(e) -> e == i end), final)
  end
  defp checkbox(false, _), do: "\e[0m#{@chosen_many_no} "
  defp checkbox(true, final), do: "\e[#{prefix(final)}m#{@chosen_many_yes} "

  defp size(choices) when is_list(choices), do: Enum.count(choices)
  defp size(choices) when is_binary(choices), do: 1

  defp delete_last_grapheme(string) do
    len = String.length(string)
    if len > 1, do: String.slice(string, 0..len-2), else: ""
  end

end

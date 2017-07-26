defmodule Hangman.Game do
  defstruct(
    turns_left: 7,
    game_state: :initial,
    letters:    [],
    used:       MapSet.new(),
  )

  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints
    }
  end
  def new_game do
    new_game(Dictionary.random_word())
  end

  def make_move(game = %{ game_state: state }, _guess) when state in [:won, :lost] do
    game
  end
  def make_move(game, guess) do
    accept_move(game, guess, MapSet.member?(game.used, guess))
  end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters:    game.letters |> reveal_guessed(game.used),
    }
  end

  # =====================================================================================

  defp accept_move(game, guess, _already_guessed = false) do
    game
    |> Map.put(:used, MapSet.put(game.used, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end
  defp accept_move(game, guess, _already_guessed) do
    Map.put(game, :game_state, :already_used)
  end

  defp score_guess(game = %{ turns_left: 1 }, _guessed = false) do
    Map.put(game, :game_state, :lost)
  end
  defp score_guess(game = %{ turns_left: turns_left }, _guessed = false) do
    %{
      game |
      game_state: :bad_guess,
      turns_left: turns_left - 1,
    }
  end
  defp score_guess(game, _guessed) do
    new_state =
      MapSet.new(game.letters)
      |> MapSet.subset?(game.used)
      |> maybe_won?
    Map.put(game, :game_state, new_state)
  end

  defp maybe_won?(true), do: :won
  defp maybe_won?(_),    do: :good_guess

  defp maybe_lose?(true), do: :lost
  defp maybe_lose?(_),    do: :bad_guess

  defp reveal_guessed(letters, used) do
    letters
    |> Enum.map(fn letter -> reveal_letter(letter, letter in used) end)
  end

  defp reveal_letter(letter, _in_word = true), do: letter
  defp reveal_letter(letter, _in_word),        do: "_"
end

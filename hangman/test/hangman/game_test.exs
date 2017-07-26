defmodule HangmanTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initial
    assert length(game.letters) > 0
  end

  test "new_game letters contains a-z letters only" do
    game = Game.new_game()

    Enum.each game.letters, &(assert &1 =~ ~r/[a-z]/)
  end

  test "state isn't changed for :won and :lost game" do
    for state <- [:won, :lost] do
      game = Game.new_game() |> Map.put(:game_state, state)

      assert game == Game.make_move(game, "")
    end
  end

  test "first occurrence of letter is not already used" do
    game = Game.new_game()
    game = Game.make_move(game, "x")

    assert "x" in game.used
    assert game.game_state != :already_used
  end

  test "second occurrence of letter is not already used" do
    game = Game.new_game()
    game = Game.make_move(game, "x")
    assert game.game_state != :already_used

    game = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognised" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "w")

    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a good guess is a won game" do
    game = Game.new_game("wibble")
    moves = [
      {"w", :good_guess},
      {"i", :good_guess},
      {"b", :good_guess},
      {"l", :good_guess},
      {"e", :won},
    ]

    Enum.reduce moves, game, fn({guess, state}, game) ->
      game = Game.make_move(game, guess)
      assert game.game_state == state
      game
    end
  end

  test "a bad guess is recognised" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "a")

    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "a bad guess is a lost game" do
    game = Game.new_game("wibble") |> Map.put(:turns_left, 1)
    game = Game.make_move(game, "a")
    assert game.game_state == :lost
  end
end

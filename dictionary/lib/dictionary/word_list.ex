defmodule Dictionary.WordList do
  def start do
    "../../assets/words.txt"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split()
  end

  def random_word(word_list) do
    Enum.random(word_list)
  end
end

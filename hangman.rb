#! /usr/bin/ruby

GUESS_COUNT = 8

class HangmanModel
  attr_reader :word, :remaining_turns

  def initialize(word)
    @word = word
    @correct_letters = []
    @remaining_turns = GUESS_COUNT
  end

  def word_guessed?
    @correct_letters.length == @word.chars.uniq.length
  end

  def contain_letter?(letter)
    @word.chars.include?(letter)
  end

  def give_correct_letter(letter)
    fail if !contain_letter?(letter)
    @correct_letters<< letter
  end

  def already_guessed?(letter)
    @correct_letters.include?(letter)
  end

  def remaining_turns?
    @remaining_turns > 0
  end

  def decrement_remaining_turns
    @remaining_turns -= 1
  end

  # gets a the word as a character array, with unguessed letters
  # being represented by 'nil'.
  def status_chars
    @word.chars.map { |c| @correct_letters.include?(c) ? c : nil }
  end
end

class HangmanController
  def initialize(model, view)
    @model = model
    @view = view
  end

  def play
    @view.show_guess_count(@model.remaining_turns)

    while @model.remaining_turns?
      play_turn

      if @model.word_guessed?
        @view.show_win_message(@model.word)
        return
      end

      @model.decrement_remaining_turns
    end

    @view.show_lose_message(@model.word)
  end

  def play_turn
    @view.show_word_status(@model.status_chars)

    letter = @view.prompt_letter

    if @model.already_guessed?(letter)
      @view.show_already_guessed_message(letter)
    else
      process_letter(letter)
    end
  end

  def process_letter(letter)
    if @model.contain_letter?(letter)
      @model.give_correct_letter(letter)
    end
  end
end

class HangmanView
  def prompt_letter
    letter = nil

    # wait for valid input
    until letter
      print("Enter a letter: ")
      letter = gets.chomp

      if letter.length != 1
        puts("Please enter a single character")
        letter = nil
      end
    end
    letter
  end

  def show_guess_count(count)
    puts "You have #{count} guesses"
  end

  def show_win_message(word)
      puts("You won! The word was '#{word}'")
  end

  def show_lose_message(word)
    puts("You ran out of turns :( The word was '#{word}'")
  end

  def show_word_status(chars)
    puts("The word is '#{current_word_status_str(chars)}'")
  end

  def show_already_guessed_message(letter)
      puts("You have already correctly guessed '#{letter}'")
  end

  def current_word_status_str(chars)
    chars.map { |c| c == nil ? '_' : c }.join
  end
end

word = File.read("words.txt").split("\n").sample()
model = HangmanModel.new(word)
view = HangmanView.new()
controller = HangmanController.new(model, view)

controller.play
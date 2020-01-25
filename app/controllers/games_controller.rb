# frozen_string_literal: true

require 'json'
require 'open-uri'
# require 'date'

# this controller controls the new and score actions
class GamesController < ApplicationController
  LETTERS = [*'A'..'Z'].freeze
  NUM_OF_LETTERS = 10

  def new
    session["total_score"] = 0 if params["reset"] == "true"
    @available_letters = []
    NUM_OF_LETTERS.times do
      index = rand(25)
      @available_letters << LETTERS[index]
    end

    @start_time = Time.now
  end

  def score
    end_time = Time.now
    start_time = Time.parse(params[:start_time])
    @time_diff = (end_time - start_time).round
    @available_letters = params[:available_letters].split
    @try = params[:try]

    @can_be_built = word_in_grid?(@try, @available_letters)
    dict = open("https://wagon-dictionary.herokuapp.com/#{@try}").read
    @exists = JSON.parse(dict)["found"]
    @score = (@try.length.to_f / @time_diff * 100).round
    if @exists && @can_be_built
      session["total_score"] = session["total_score"] ? session["total_score"] + @score : @score
    end
    @total_score = session["total_score"]
  end

  def word_in_grid?(word, letters)
    char_array = word.split('').map(&:upcase)
    correct = true
    char_array.each do |char|
      i = letters.index(char)
      i ? letters.delete_at(i) : correct = false
    end
    correct
  end
end

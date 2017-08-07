class PagesController < ApplicationController
  def game
    @grid = generate_grid(9)
    @start_time = Time.now.to_i
  end


def score
  @word = params[:word]
  @grid = params[:grid]
  @start_time = params[:start_time].to_i
  @guessgrid = included?(@word, @grid)
  @end_time = Time.now.to_i
  # @time = @end_time - @start_time
  @result = run_game(@word, @grid, @start_time, @end_time)

end

private

  def generate_grid(x)
    grid = []
    x.times do
      grid << ('A'..'Z').to_a.sample
    end
    grid.join
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

end

class PagesController < ApplicationController
  def game
    @grid = generate_grid(9)
    @start = Time.now.to_i
  end

  def score
    @start = params[:start].to_i
    @word = params[:word].upcase
    @grid = params[:grid]
    @time = Time.now.to_i - @start
    #@test = included?(@word, @grid)
    #@time = @end - @start
    #@score = compute_score(@word, @time)
    @game = run_game(@word, @grid, @time)
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }.join(" ")
  end

  def time_shot
    start_time = Time.now
    end_time = Time.now
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(word, time)
    (time > 60.0) ? 0 : word.size * (1.0 - time / 60.0)
  end

  def get_translation(word)
    api_key = "65926508-a0be-4e4a-9c96-b5dba693ead0"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def run_game(attempt, grid, time)
    result = { time: time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

end

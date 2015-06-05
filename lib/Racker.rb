require 'json'

class Racker
  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session[:game] ||= new_game
    @game = @request.session[:game]
  end

  def new_game
    game = Codebreaker::Game.new
    game.start
    game
  end

  # def game
  #   @request.session[:game]
  # end

  def restart_game(response)
    response.delete_cookie("hint")
    @request.session.delete("guesses")
    @game.start
  end

  def self.call(env)
    new(env).response.finish
  end

  def response
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/update_guess" then compare
    when "/new_game"
      Rack::Response.new do |response|
        restart_game(response)
        response.redirect("/")
      end
    when "/get_hint" then hint
    when "/create_user"
      Rack::Response.new do |response|
        save(@request.params["user"])
        restart_game(response)
        response.redirect("/")
      end
    else Rack::Response.new("Not Found", 404)
    end
end

  def render(template)
    path = File.expand_path("../../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def hint
    game_hint = @game.hintUsed ? "Already used your hint." : @game.hint
    Rack::Response.new({ hint: game_hint }.to_json)
  end

  # def guess
  #   code = @request.params['guess']
  #   result = @game.compare(code)
  #   Rack::Response.new({ code: code, result: result }.to_json)
  # end

  def compare
    answer = @request.params['guess'].chomp.downcase
    if @game.valid? answer
      if @game.turnsCount < -1 + Codebreaker::Game::MAX_TURNS_COUNT
        result = @game.compare(answer)
      elsif @game.turnsCount == Codebreaker::Game::MAX_TURNS_COUNT && @game.compare(answer) == "++++"
        result = "++++"
      else
        result = "lost"
      end
    else
      result = "Something is wrong with your input."
    end
    Rack::Response.new({ code: answer, result: result }.to_json)
  end

  def save(name)
    begin
      path = File.expand_path("../../data/data.txt", __FILE__)
      File.open(path, 'a') do |f|
        hintPenalty = @game.hintUsed ? 100 : 0
        points = 1200 - @game.turnsCount*100 - hintPenalty
        f.write("#{name} __________________ #{points}\n")
      end
    rescue
      "Your result wasn't saved."
    end
  end

  def statistics
    path = File.expand_path("../../data/data.txt", __FILE__)
    File.readlines(path).each do |line|
    end
  end

end
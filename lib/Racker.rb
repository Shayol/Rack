class Racker
  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session[:game] ||= new_game
    @game = @request.session[:game]
    @request.session[:guesses] ||= {}
    @guesses = @request.session[:guesses]
  end

  def new_game
    game = Codebreaker::Game.new
    game.start
    game
  end

  def restart_game(response)
    response.set_cookie("hint", nil)
    @request.session[:guesses] = {}
    @game.start
  end

  def self.call(env)
    new(env).response.finish
  end

  def response
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/update_guess"
      Rack::Response.new do |response|
        restart_game(response) if @guesses.values.include? 'lost'
        compare(@request.params["guess"])
        response.redirect("/")
      end
    when "/new_game"
      Rack::Response.new do |response|
        restart_game(response)
        response.redirect("/")
      end
    when "/get_hint"
    Rack::Response.new do |response|
      game_hint = @game.hintUsed ? "Already used your hint." : @game.hint
      response.set_cookie("hint", game_hint)
      response.redirect("/")
    end
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
    @request.cookies["hint"]
  end

  def compare(answer)
    answer = answer.chomp.downcase
    if @game.valid? answer
      if @game.turnsCount < -1 + Codebreaker::Game::MAX_TURNS_COUNT
        result = @game.compare(answer)
          @guesses[answer] = result
      elsif @game.turnsCount == Codebreaker::Game::MAX_TURNS_COUNT && @game.compare(answer) == "++++"
        @guesses[answer] = "++++"
      else
        @guesses[answer] = "lost"
      end
    else
      @guesses[answer] = "Something is wrong with your input."
    end
    @guesses
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
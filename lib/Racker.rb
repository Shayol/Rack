class Racker
  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session[:game] ||= new_game
    @game = @request.session[:game]
    puts "#{@game}"
  end

  def new_game
    game = Codebreaker::Game.new
    game.start
    game
  end

  def self.call(env)
    new(env).response.finish
  end

  def response
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/update_guess"
      Rack::Response.new do |response|
        response.set_cookie("guess", compare(@request.params["guess"]))
        #S@request.session[:game] = @game
        response.redirect("/")
      end
    when "/new_game"
      Rack::Response.new do |response|
        response.set_cookie("guess", nil)
        response.set_cookie("hint", nil)
        @game.start
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
        response.set_cookie("guess", nil)
        response.set_cookie("hint", nil)
        @game.start
        response.redirect("/")
      end
    else Rack::Response.new("Not Found", 404)
    end
end

  def render(template)
    path = File.expand_path("../../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def guess
    @request.cookies["guess"]
  end

  def hint
    @request.cookies["hint"]
  end

  def compare(answer)
    answer = answer.chomp.downcase
    if @game.valid? answer
      if @game.turnsCount < Codebreaker::Game::MAX_TURNS_COUNT
        result = @game.compare(answer)
          answer << ": " << result
      else
        "You lost"
      end
    else
      "Something is wrong with your input."
    end
  end

  def save(name)
    begin
      path = File.expand_path("../../data/data.txt", __FILE__)
      File.open(path, 'a') do |f|
        hintPenalty = @game.hintUsed ? 100 : 0
        points = 1200 - @game.turnsCount*100 - hintPenalty
        f.write("#{name} __________________ #{points}")
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
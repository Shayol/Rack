class Racker
  def initialize
    clean_up_data_instances
    @saved_game = Game.create(guess: '')
    @game = Codebreaker::Game.new
    @game.start
  end

  def clean_up_data_instances
    @saved_game.destroy if @saved_game
    @game=nil
  end

  def current_game
    @saved_game
  end

  def call(env)
    @request = Rack::Request.new(env)
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/update_guess"
      Rack::Response.new do |response|
        current_game.update_attribute(:guess, current_game.guess << guess(@request.params["guess"]))
        response.redirect("/")
      end
    when "/new_game"
      Rack::Response.new do |response|
        initialize
        response.redirect("/")
      end
    when "/get_hint"
    Rack::Response.new do |response|
      game_hint = @game.hintUsed ? "Already used your hint." : @game.hint
      current_game.update_attribute(:hint, game_hint)
      response.redirect("/")
    end
    when "/create_user"
      Rack::Response.new do |response|
        create_user(@request.params["user"])
        response.redirect("/")
      end
    else Rack::Response.new("Not Found", 404)
    end.finish
end

  def render(template)
    path = File.expand_path("../../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def guess(answ=nil)
    return unless answ && @game
    answer = answ.chomp.downcase
    message = ''
    return message << answer << ': ' << "Something is wrong with your input" << "\n\n" unless @game.valid? answer
    message << answer << ': ' << @game.compare(answer) << "\n\n "
    won_lost
    message
    end

  def won_lost
    if @game.won
      current_game.update_attribute(:won_lost, 'won')
    elsif @game.turnsCount >= Codebreaker::Game::MAX_TURNS_COUNT
      current_game.update_attribute(:won_lost, 'lost')
      #clean_up_data_instances
    end
  end

  def create_user(name)
    user = User.create(name: name, attempts: "{@game.turnsCount}", hintUsed: @game.hintUsed)
    #statistics
    clean_up_data_instances
  end

  def statistics
    User.all.order(:attempts).limit(15)
  end

end
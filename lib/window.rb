class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = 'BBB - MINI JAM 48'
    @font        = Gosu::Font.new(40, name: 'font/Copperplate Gothic Bold Regular.ttf')
    @keystates   = {}
    @title       = Gosu::Image.new('gfx/title.png', retro: true)
    @infos       = Gosu::Image.new('gfx/infos.png', retro: true)
    @end_screen  = Gosu::Image.new('gfx/game_over.png', retro: true)
    @win_screen  = Gosu::Image.new('gfx/game_finished.png', retro: true)
    @state       = :title
    @level       = 1
    @click_sound = Gosu::Sample.new('sfx/Click2-Sebastian-759472264.wav')
    @alert_sound = Gosu::Sample.new('sfx/sms-alert-1-daniel_simon.wav')
    @music       = Gosu::Song.new('sfx/TeamWork_MiniJam.ogg')
    # @music.play
  end

  def load_game
    # temp
    @level = 2

    @camera = Camera.new(self)
    @hero   = Hero.new
    @map    = Map.new(self, "level_#{@level}")
    @state  = :game
    @hero.set_position(*@map.get_start_position.map {|e| e * 16})
  end

  def needs_cursor?; true; end

  def button_down(id)
    super
    close! if id == Gosu::KB_ESCAPE
    @keystates[id] = true
  end

  def button_up(id)
    @keystates[id] = false
  end

  def next_level
    @score += 500

    levels = Dir.entries('maps/').select {|e| e.include?('.png')}

    if @level + 1 <= levels.size
      @level += 1
      load_game
    else
      diff_time = Time.now - @timer
      mins = (diff_time / 60).floor
      secs = (diff_time - (mins * 60)).floor
      @final_time = "#{mins} min and #{secs} seconds"
      game_finished
    end
  end

  def back_to_title
    @level = 1
    @state = :title
  end

  def game_over
    @alert_sound.play
    @score -= 100
    @state = :game_over
  end

  def game_finished
    @state = :game_finished
  end

  def update
    case @state
    when :title
      @blink_time ||= 0
      @blink_time += 1
      @blink_time = 0 if @blink_time > 100

      if @keystates[Gosu::KB_RETURN]
        @keystates[Gosu::KB_RETURN] = false
        @click_sound.play
        @state = :infos
      end
    when :infos
      @blink_time ||= 0
      @blink_time += 1
      @blink_time = 0 if @blink_time > 100

      if @keystates[Gosu::KB_RETURN]
        @keystates[Gosu::KB_RETURN] = false
        @click_sound.play
        @timer = Time.now
        @score = 0
        load_game
      end      
    when :game_over
      @blink_time ||= 0
      @blink_time += 1
      @blink_time = 0 if @blink_time > 100

      if @keystates[Gosu::KB_RETURN]
        @keystates[Gosu::KB_RETURN] = false
        @click_sound.play
        load_game
      end
    when :game_finished
      @blink_time ||= 0
      @blink_time += 1
      @blink_time = 0 if @blink_time > 100

      if @keystates[Gosu::KB_RETURN]
        @keystates[Gosu::KB_RETURN] = false
        @click_sound.play
        back_to_title
      end
    when :game
      @map.update(@hero.x, @hero.z)
      @hero.update(@map)
      @camera.update(@hero.x, @hero.y, @hero.z)
    end
  end

  def draw
    case @state
    when :title
      @title.draw(0, 0, 0)
      if @blink_time < 50
        @font.draw_text("Press Enter to Start", 20, 430, 1)
        @font.draw_text("Press Enter to Start", 21, 431, 0, 1, 1, Gosu::Color::BLACK)
      end
    when :infos
      @infos.draw(0, 0, 0)
      if @blink_time < 50
        @font.draw_text("Press Enter to Start", 20, 430, 1, 1, 1, Gosu::Color::BLACK)
        @font.draw_text("Press Enter to Start", 21, 431, 0, 1, 1, Gosu::Color::WHITE)
      end
    when :game_over
      @end_screen.draw(0, 0, 0)
      if @blink_time < 50
        @font.draw_text("Press Enter to Retry", 20, 430, 1)
        @font.draw_text("Press Enter to Retry", 21, 431, 0, 1, 1, Gosu::Color::BLACK)
      end     
    when :game_finished
      @win_screen.draw(0, 0, 0)
      @font.draw_text("Score : #{@score}", 40, 40, 1)
      @font.draw_text("Time  : #{@final_time}", 40, 80, 1)

      if @blink_time < 50
        @font.draw_text("Press Enter to Restart", 20, 430, 1)
        @font.draw_text("Press Enter to Restart", 21, 431, 0, 1, 1, Gosu::Color::BLACK)
      end   
    when :game
      gl do
        @camera.look
        @map.draw
        @hero.draw(@camera.angle, @camera.angle_v)
      end

      @map.draw_minimap(@hero.x, @hero.z)
    end
  end
end

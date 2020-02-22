class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = 'MINI JAM 48'

    @camera = Camera.new(self)

    @hero = Hero.new

    @map = Map.new(self, 'test')
    @hero.set_position(*@map.get_start_position.map {|e| e * 16})
  end

  def needs_cursor?; true; end

  def button_down(id)
    super
    close! if id == Gosu::KB_ESCAPE
  end

  def game_over
    self.caption = "game over"
  end

  def update
    self.caption = ""
    @map.update(@hero.x, @hero.z)
    @hero.update(@map)
    @camera.update(@hero.x, @hero.y, @hero.z)
  end

  def draw
    gl do
      @camera.look
      @map.draw
      @hero.draw(@camera.angle, @camera.angle_v)
    end

    @map.draw_minimap(@hero.x, @hero.z)

    @font ||= Gosu::Font.new(24)
    @font.draw_text("FPS : #{Gosu::fps}", 10, 10, 1)
  end
end

class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = 'MINI JAM 48'

    @camera = Camera.new(self)

    @hero = Hero.new

    @map = Map.new
  end

  def needs_cursor?; true; end

  def button_down(id)
    super
    close! if id == Gosu::KB_ESCAPE
  end

  def update
    @hero.update
    @camera.update(@hero.x, @hero.y + 32, @hero.z)
  end

  def draw
    gl do
      @camera.look
      @map.draw
      @hero.draw(@camera.angle)
    end

    @font ||= Gosu::Font.new(24)
    @font.draw_text("FPS : #{Gosu::fps}", 10, 10, 1)
  end
end

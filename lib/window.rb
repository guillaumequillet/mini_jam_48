class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = 'MINI JAM 48'

    @desk = ObjModel.new('desk')

    @camera = Camera.new({
      x: 0,
      y: 50, 
      z: 50,
      t_x: 0,
      t_y: 0,
      t_z: 0,
      fovy: 45,
      ratio: self.width.to_f / self.height,
      distance: 32
    })

    @hero = Hero.new
  end

  def needs_cursor?; true; end

  def button_down(id)
    close! if id == Gosu::KB_ESCAPE
  end

  def update
    @hero.update
    @camera.update(@hero.x, @hero.y, @hero.z)
  end

  def draw
    gl do
      @camera.look

      @angle ||= 0
      @angle += 1
      glRotatef(@angle, 0, 1, 0)

      @desk.draw(0, 0, -32)
      @hero.draw(0)
    end
  end
end

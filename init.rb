require 'gosu'

class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = 'MINI JAM 48'
  end

  def button_down(id)
    close! if id == Gosu::KB_ESCAPE
  end

  def update

  end

  def draw

  end
end

Window.new.show

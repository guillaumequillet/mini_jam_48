class Camera
  attr_reader :angle

  def initialize(window)
    @window   = window
    @x        = 0
    @y        = 0
    @z        = 0
    @t_x      = 0
    @t_y      = 0
    @t_z      = 0
    @fovy     = 45
    @distance = 96
    @near     = 1
    @far      = 1000
    @angle    = 90
    @angle_v  = 20
  end

  def look
    @ratio = @window.fullscreen? ? Gosu::screen_width.to_f / Gosu::screen_height : (@window.width.to_f / @window.height)

    glEnable(GL_TEXTURE_2D)
    glEnable(GL_DEPTH_TEST)

    glClearColor(1.0, 0.0, 1.0, 0.0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(@fovy, @ratio, @near, @far)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    gluLookAt(@x, @y, @z,  @t_x, @t_y, @t_z,  0, 1, 0)
  end

  def update(target_x, target_y, target_z)
    @angle_v += 1 if Gosu::button_down?(Gosu::KB_R)
    @angle_v -= 1 if Gosu::button_down?(Gosu::KB_F)

    @t_x = target_x
    @t_y = target_y
    @t_z = target_z

    temp_v = Math.cos(@angle_v * Math::PI / 180.0)
    @x = @t_x + @distance * temp_v * Math::cos(@angle * Math::PI / 180.0)
    @z = @t_z + @distance * temp_v * Math::sin(@angle * Math::PI / 180.0)
    @y = @t_y + @distance * Math::sin(@angle_v * Math::PI / 180.0)
  end
end

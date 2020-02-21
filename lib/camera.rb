class Camera
  def initialize(attribs = {})
    @x        = attribs[:x]
    @y        = attribs[:y]
    @z        = attribs[:z]
    @t_x      = attribs[:t_x]
    @t_y      = attribs[:t_y]
    @t_z      = attribs[:t_z]
    @fovy     = attribs[:fovy]
    @ratio    = attribs[:ratio]
    @distance = attribs[:distance]
    @near     = 1
    @far      = 1000
    @angle    = 0
  end

  def look
    glEnable(GL_TEXTURE_2D)
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_ALPHA_TEST)
    glAlphaFunc(GL_GREATER, 0)

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

  end
end

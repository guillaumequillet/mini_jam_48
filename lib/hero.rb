class Hero
  attr_reader :x, :y, :z

  def initialize
    @sprites = Gosu::Image.load_tiles("gfx/sprites/hero.png", 32, 32, retro: true)
    @x, @y, @z = 0, 0, 0
  end

  def update
    v = 1
    @z -= v if Gosu::button_down?(Gosu::KB_W) or Gosu::button_down?(Gosu::KB_UP)
    @z += v if Gosu::button_down?(Gosu::KB_S) or Gosu::button_down?(Gosu::KB_DOWN)
    @x -= v if Gosu::button_down?(Gosu::KB_A) or Gosu::button_down?(Gosu::KB_LEFT)
    @x += v if Gosu::button_down?(Gosu::KB_D) or Gosu::button_down?(Gosu::KB_RIGHT)
  end

  def draw(camera_angle = 0)
    glEnable(GL_ALPHA_TEST)
    glAlphaFunc(GL_GREATER, 0)

    @frames = [6,7,6,8]
    @frame ||= 0
    @frame_time ||= 0

    @frame_time += 1

    if @frame_time > 10
      @frame += 1 
      @frame_time = 0
      @frame = 0 if @frame > @frames.size - 1
    end

    sprite = @sprites[@frames[@frame]]

    glBindTexture(GL_TEXTURE_2D, sprite.gl_tex_info.tex_name)
    l, r, t, b = sprite.gl_tex_info.left, sprite.gl_tex_info.right, sprite.gl_tex_info.top, sprite.gl_tex_info.bottom
    glPushMatrix
      glTranslatef(@x, @y, @z)
      glScalef(sprite.width, sprite.height, 1)
      glRotatef(90 - camera_angle, 0, 1, 0)
      glBegin(GL_QUADS)
        glTexCoord2d(l, t); glVertex3f(-0.5, 1.0, 0.0)
        glTexCoord2d(l, b); glVertex3f(-0.5, 0.0, 0.0)
        glTexCoord2d(r, b); glVertex3f(0.5, 0.0, 0.0)
        glTexCoord2d(r, t); glVertex3f(0.5, 1.0, 0.0)
      glEnd
    glPopMatrix

    glDisable(GL_ALPHA_TEST)
  end
end

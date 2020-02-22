class Hero
  attr_reader :x, :y, :z

  def initialize
    @sprites = Gosu::Image.load_tiles("gfx/sprites/hero.png", 32, 32, retro: true)
    @x, @y, @z = 0, 0, 0
  end

  def set_position(x, y, z)
    @x, @y, @z = x, y, z
  end

  def update
    @frames ||= [0,1,0,2]
    @frame ||= 0
    @frame_time ||= 0

    v = 1

    y_key = ([Gosu::KB_W, Gosu::KB_UP, Gosu::KB_S, Gosu::KB_DOWN].any? {|key| Gosu::button_down?(key)})
    x_key = ([Gosu::KB_A, Gosu::KB_LEFT, Gosu::KB_D, Gosu::KB_RIGHT].any? {|key| Gosu::button_down?(key)})
      
    if x_key && y_key
      v *= 0.7
    end

    if Gosu::button_down?(Gosu::KB_W) or Gosu::button_down?(Gosu::KB_UP)
      @z -= v
      @frames = [3,4,3,5]
    end

    if Gosu::button_down?(Gosu::KB_S) or Gosu::button_down?(Gosu::KB_DOWN)
      @z += v 
      @frames = [0,1,0,2]
    end

    if Gosu::button_down?(Gosu::KB_A) or Gosu::button_down?(Gosu::KB_LEFT)
      @x -= v 
      @frames = [9,10,9,11]
    end

    if Gosu::button_down?(Gosu::KB_D) or Gosu::button_down?(Gosu::KB_RIGHT)
      @x += v
      @frames = [6,7,6,8]
    end

    keys = [Gosu::KB_W, Gosu::KB_A, Gosu::KB_S, Gosu::KB_D, Gosu::KB_LEFT, Gosu::KB_RIGHT, Gosu::KB_UP, Gosu::KB_DOWN]
    unless keys.any? {|key| Gosu::button_down?(key)}
      @frame = 0
    else 
      @frame_time += 1
      if @frame_time > 8
        @frame += 1 
        @frame_time = 0
        @frame = 0 if @frame > @frames.size - 1
      end 
    end
  end

  def draw(camera_angle = 0, camera_angle_v = 0)
    glEnable(GL_ALPHA_TEST)
    glAlphaFunc(GL_GREATER, 0)

    sprite = @sprites[@frames[@frame]]

    glBindTexture(GL_TEXTURE_2D, sprite.gl_tex_info.tex_name)
    l, r, t, b = sprite.gl_tex_info.left, sprite.gl_tex_info.right, sprite.gl_tex_info.top, sprite.gl_tex_info.bottom
    glPushMatrix
      glTranslatef(@x, @y, @z)
      glRotatef(-camera_angle_v, 1, 0, 0)
      glRotatef(90 - camera_angle, 0, 1, 0)
      glScalef(sprite.width, sprite.height, 1)

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

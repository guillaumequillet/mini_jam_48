class Hero
  attr_reader :x, :y, :z
  
  def initialize
    @sprite = Gosu::Image.new("gfx/sprites/hero.png", retro: true)
    @x, @y, @z = 0, 0, 0
  end

  def update

  end

  def draw(camera_angle = 0)
    glBindTexture(GL_TEXTURE_2D, @sprite.gl_tex_info.tex_name)
    l, r, t, b = @sprite.gl_tex_info.left, @sprite.gl_tex_info.right, @sprite.gl_tex_info.top, @sprite.gl_tex_info.bottom
    glPushMatrix
      glTranslatef(@x, @y, @z)
      glScalef(@sprite.width, @sprite.height, 1)
      # glRotatef(90 - camera_angle, 0, 1, 0)
      glBegin(GL_QUADS)
        glTexCoord2d(l, t); glVertex3f(-0.5, 1.0, 0.0)
        glTexCoord2d(l, b); glVertex3f(-0.5, 0.0, 0.0)
        glTexCoord2d(r, b); glVertex3f(0.5, 0.0, 0.0)
        glTexCoord2d(r, t); glVertex3f(0.5, 1.0, 0.0)
      glEnd
    glPopMatrix
  end
end

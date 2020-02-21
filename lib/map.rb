class Map
  def initialize

  end

  def draw
    @desk ||= ObjModel.new('desk', true)
    @tileset ||= GLTexture.load_tiles('gfx/tileset.png', 16, 16)
    
    w, l = 5, 5
    glBindTexture(GL_TEXTURE_2D, @tileset[1].get_id)
    glPushMatrix
    glScalef(w * 16, 1, l * 16)
    glBegin(GL_QUADS)
      glTexCoord2d(0, 0); glVertex3f(0, 0, 0)
      glTexCoord2d(0, l); glVertex3f(0, 0, 1)
      glTexCoord2d(w, l); glVertex3f(1, 0, 1)
      glTexCoord2d(w, 0); glVertex3f(1, 0, 0)
    glEnd
    glPopMatrix

    # w, l = 5, 5
    # glBindTexture(GL_TEXTURE_2D, @tileset[0].get_id)
    # glPushMatrix
    # glScalef(w * 16, 48, l * 16)
    # glBegin(GL_QUADS)
    #   glTexCoord2d(0, 0); glVertex3f(0, 1, 0)
    #   glTexCoord2d(0, l); glVertex3f(0, 1, 1)
    #   glTexCoord2d(w, l); glVertex3f(1, 1, 1)
    #   glTexCoord2d(w, 0); glVertex3f(1, 1, 0)
    # glEnd
    # glPopMatrix


    @desk.draw(0, 0, 0)  
  end
end

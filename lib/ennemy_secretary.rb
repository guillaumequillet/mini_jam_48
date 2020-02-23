class SecretaryEnnemy < Ennemy
  def initialize(map, x, z)
    super(map, x, z)
    @chair        = ObjModel.new('chair', true)
    @sprites      = GLTexture.load_tiles('gfx/sprites/secretary_newspaper.png', 32, 32) 
    @sprite       = 0
    @tiles_range  = 4
  end

  def update
    @frame_time ||= 0

    @frame_time += 1
    if (@frame_time > 50)
      @sprite += 1
      @frame_time = 0
      @sprite = 0 if @sprite > @sprites.size - 1
    end
  end

  def sees_hero?(hero_x, hero_z)
    hero_tile_x = (hero_x / 16.0).floor
    hero_tile_z = (hero_z / 16.0).floor

    if (@sprite == 2)
      if hero_tile_x == @x
        if hero_tile_z > @z && hero_tile_z <= @z + @tiles_range  
          return true
        end
      end 
    end

    return false
  end

  def draw
    x, y, z = (@x + 0.5) * @map.tile_size, 0, (@z + 0.5) * @map.tile_size
    
    # chair 3D model
    @chair.draw(x + 8, y, z + 4, 180)
    
    glBindTexture(GL_TEXTURE_2D, @sprites[@sprite].get_id)
    glEnable(GL_ALPHA_TEST)
    glAlphaFunc(GL_GREATER, 0)
    glPushMatrix
      glTranslatef(x, 0, z)
      glScalef(32, 32, 1)
      glBegin(GL_QUADS)
        glTexCoord2d(0, 0); glVertex3f(-0.5, 1.0, 0.0)
        glTexCoord2d(0, 1); glVertex3f(-0.5, 0.0, 0.0)
        glTexCoord2d(1, 1); glVertex3f(0.5, 0.0, 0.0)
        glTexCoord2d(1, 0); glVertex3f(0.5, 1.0, 0.0)
      glEnd
    glPopMatrix
    glDisable(GL_ALPHA_TEST)
  end
end

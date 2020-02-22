class TurningEnnemy < Ennemy
  def initialize(map, x, z)
    super(map, x, z)
    @chair        = ObjModel.new('chair2', true)
    @sprites      = GLTexture.load_tiles('gfx/sprites/enney_turning.png', 32, 32) 
    @sprite       = 0
    @sprite_angle = 0
    @rot_speed    = 2
    @tiles_range  = 3
  end

  def update
    @angle += @rot_speed
    @sprite_angle += (@rot_speed * 2)
    @angle = 0 if @angle >= 360.0
    @sprite_angle = 0 if @sprite_angle >= 360.0

    @sprite = (@sprite_angle / 90.0).floor
  end

  def sees_hero?(hero_x, hero_z)
    hero_tile_x = (hero_x / 16.0).floor
    hero_tile_z = (hero_z / 16.0).floor

    case @sprite
    when 0 # looking down
      return @x == hero_tile_x && hero_tile_z - @z <= @tiles_range && hero_tile_z - @z > 0
    when 1 # looking right
      return @z == hero_tile_z && hero_tile_x - @x <= @tiles_range && hero_tile_x - @x > 0
    when 2 # looking up
      return @x == hero_tile_x && @z - hero_tile_z <= @tiles_range && @z - hero_tile_z > 0
    when 3 # looking left
      return @z == hero_tile_z && @x - hero_tile_x <= @tiles_range && @x - hero_tile_x > 0
    end
  end

  def draw
    x, y, z = (@x + 0.5) * @map.tile_size, 0, (@z + 0.5) * @map.tile_size
    
    # chair 3D model
    @chair.draw(x, y, z, @angle)
    
    # "rotating" sprite
    glBindTexture(GL_TEXTURE_2D, @sprites[@sprite].get_id)
    glEnable(GL_ALPHA_TEST)
    glAlphaFunc(GL_GREATER, 0)
    glPushMatrix
      glTranslatef(x, 5, z)
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

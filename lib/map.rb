class Map
  def initialize(filename)
    @tileset = GLTexture.load_tiles('gfx/tileset.png', 16, 16)
    @wallset = GLTexture.load_tiles('gfx/wallset.png', 16, 48)

    @assets = {
      desk:    ObjModel.new('desk', true)
    }

    read_file(filename)
  end

  def read_file(filename)
    transparent_color = Gosu::Color.new(255, 255, 0, 255)
    @tiles   = []
    @walls   = [] 
    @models  = []
    @minimap = Gosu::Image.new("maps/#{filename}.png", retro: true)

    @minimap.height.times do |y|
      @minimap.width.times do |x|
        color = @minimap.get_pixel(x, y)
        tile = nil
        unless color == transparent_color
          case color
          when Gosu::Color::WHITE
            tile = 1
          when Gosu::Color::BLUE
            tile = 1
            set_start_position(x, y)
          when Gosu::Color::GREEN
            tile = 1
            @models.push [:desk, x, y]
          when Gosu::Color::BLACK
            @walls.push [x, y]
          end
          @tiles[y * @minimap.width + x] = tile
        end
      end
    end

    @models.each do |model|
      shape, x, z = *model
      if shape == :desk
        @tiles[convert_coords_to_index(x, z)] = 2
        @tiles[convert_coords_to_index(x + 1, z)] = 2
      end
    end
  end

  def set_start_position(x, z)
    @start_position = [x, 0, z]
  end

  def get_start_position
    @start_position
  end

  def convert_index_to_coords(i)
    y = i / @minimap.width
    x = i % @minimap.width
    [x, y]
  end

  def convert_coords_to_index(x, y)
    @minimap.width * y + x
  end

  def draw_floor
    last_loaded_texture = nil

    glPushMatrix
    glScalef(@tileset[0].width, 1, @tileset[1].height)

    @tiles.each_with_index do |tile, i|
      next if tile.nil?

      x, z = *convert_index_to_coords(i)
      if last_loaded_texture.nil? or last_loaded_texture != tile
        glBindTexture(GL_TEXTURE_2D, @tileset[tile].get_id)
        last_loaded_texture = tile
      end

      glBegin(GL_QUADS)
        glTexCoord2d(0, 0); glVertex3f(x, 0, z)
        glTexCoord2d(0, 1); glVertex3f(x, 0, z + 1)
        glTexCoord2d(1, 1); glVertex3f(x + 1, 0, z + 1)
        glTexCoord2d(1, 0); glVertex3f(x + 1, 0, z)
      glEnd
    end
    glPopMatrix
  end

  def draw_roof
    glPushMatrix
    glScalef(@tileset[0].width, @wallset[0].height, @tileset[1].height)

    @walls.each do |wall|
      x, z = *wall
      glBindTexture(GL_TEXTURE_2D, @tileset[0].get_id)

      glBegin(GL_QUADS)
        glTexCoord2d(0, 0); glVertex3f(x, 1, z)
        glTexCoord2d(0, 1); glVertex3f(x, 1, z + 1)
        glTexCoord2d(1, 1); glVertex3f(x + 1, 1, z + 1)
        glTexCoord2d(1, 0); glVertex3f(x + 1, 1, z)
      glEnd
    end
    glPopMatrix
  end

  def draw_walls
    glBindTexture(GL_TEXTURE_2D, @wallset[0].get_id)
    glPushMatrix
    glScalef(@wallset[0].width, @wallset[0].height, @wallset[0].width)
    glBegin(GL_QUADS)
    @walls.each do |wall|
      x, z = *wall

      # left wall
      if !@tiles[convert_coords_to_index(x-1, z)].nil? && !@walls.include?([x-1, z])
        glColor3ub(128, 128, 128)
        glTexCoord2d(0, 0); glVertex3f(x, 1, z)
        glTexCoord2d(0, 1); glVertex3f(x, 0, z)
        glTexCoord2d(1, 1); glVertex3f(x, 0, z+1)
        glTexCoord2d(1, 0); glVertex3f(x, 1, z+1)
      end

      # right wall
      if !@tiles[convert_coords_to_index(x+1, z)].nil? && !@walls.include?([x+1, z])
        glColor3ub(128, 128, 128)
        glTexCoord2d(0, 0); glVertex3f(x+1, 1, z)
        glTexCoord2d(0, 1); glVertex3f(x+1, 0, z)
        glTexCoord2d(1, 1); glVertex3f(x+1, 0, z+1)
        glTexCoord2d(1, 0); glVertex3f(x+1, 1, z+1)
      end

      # back wall
      if !@tiles[convert_coords_to_index(x, z-1)].nil? && !@walls.include?([x, z-1])
        glColor3ub(255, 255, 255)
        glTexCoord2d(0, 0); glVertex3f(x, 1, z)
        glTexCoord2d(0, 1); glVertex3f(x, 0, z)
        glTexCoord2d(1, 1); glVertex3f(x+1, 0, z)
        glTexCoord2d(1, 0); glVertex3f(x+1, 1, z)
      end

      # front wall
      if !@tiles[convert_coords_to_index(x, z+1)].nil? && !@walls.include?([x, z+1])
        glColor3ub(255, 255, 255)
        glTexCoord2d(0, 0); glVertex3f(x, 1, z+1)
        glTexCoord2d(0, 1); glVertex3f(x, 0, z+1)
        glTexCoord2d(1, 1); glVertex3f(x+1, 0, z+1)
        glTexCoord2d(1, 0); glVertex3f(x+1, 1, z+1)
      end
    end
    glEnd
    glPopMatrix
    glColor3ub(255, 255, 255)
  end

  def draw
    unless defined?(@display_list)
      @display_list = glGenLists(1)
      glNewList(@display_list, GL_COMPILE)
        draw_floor
        draw_roof
        draw_walls
      
        @models.each do |model|
          shape, x, z = *model
          @assets[shape].draw(x * @tileset[0].width, 0, z * @tileset[0].height)
        end
      glEndList
    end
    glCallList(@display_list)
  end
end

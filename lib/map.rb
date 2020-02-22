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
    @tiles = []
    @models = []
    @minimap = Gosu::Image.new("maps/#{filename}.png", retro: true)
    @minimap.height.times do |y|
      @minimap.width.times do |x|
        color = @minimap.get_pixel(x, y)
        tile = nil
        unless color == transparent_color
          case color
          when Gosu::Color::WHITE
            tile = 1
          when Gosu::Color::GREEN
            tile = 1
            @models.push [:desk, x, y]
          when Gosu::Color::BLACK

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

  def convert_index_to_coords(i)
    y = i / @minimap.width
    x = i % @minimap.width
    [x, y]
  end

  def convert_coords_to_index(x, y)
    @minimap.width * y + x
  end

  def draw
    unless defined?(@display_list)
      @display_list = glGenLists(1)
      glNewList(@display_list, GL_COMPILE)

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
      
        @models.each do |model|
          shape, x, z = *model
          @assets[shape].draw(x * @tileset[0].width, 0, z * @tileset[0].height)
        end
      glEndList
    end
    glCallList(@display_list)
  end
end

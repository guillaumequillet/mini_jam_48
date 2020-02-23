class Map
  attr_reader :tile_size

  def initialize(window, filename)
    @window    = window
    @tile_size = 16
    @tileset   = GLTexture.load_tiles('gfx/tileset.png', @tile_size, @tile_size)
    @wallset   = GLTexture.load_tiles('gfx/wallset.png', @tile_size, @tile_size * 3)

    @assets = {
      desk:              ObjModel.new('desk', true),
      desk2:             ObjModel.new('desk2', true),
      plant:             ObjModel.new('plant', true),
      fire_extinguisher: ObjModel.new('fire_extinguisher', true),
      coffee:            ObjModel.new('coffee'),
      chair:             ObjModel.new('chair', true)
    }

    read_file(filename)
  end

  def read_file(filename)
    transparent_color = Gosu::Color.new(255, 255, 0, 255)
    @tiles    = []
    @walls    = [] 
    @models   = []
    @blocks   = []
    @ennemies = []
    @minimap  = Gosu::Image.new("maps/#{filename}.png", retro: true)

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
          when Gosu::Color.new(255, 64, 255, 64)
            tile = 1
            @models.push [:desk2, x, y]
          when Gosu::Color.new(255, 113, 176, 18)
            tile = 1
            @models.push [:plant, x, y]
          when Gosu::Color.new(255, 173, 173, 173)
            tile = 1
            @models.push [:chair, x, y]
          when Gosu::Color.new(255, 237, 128, 143)
            tile = 1
            @models.push [:fire_extinguisher, x, y]
          when Gosu::Color.new(255, 117, 126, 133)
            tile = 1
            @models.push [:coffee, x, y]
          when Gosu::Color::RED
            tile = 1
            set_end_position(x, y)
          # ennemies
          when Gosu::Color.new(255, 127, 0, 55)
            tile = 3
            @ennemies.push(TurningEnnemy.new(self, x, y))
            @blocks.push [x, y]
          when Gosu::Color.new(255, 255, 216, 0)
            tile = 3
            @ennemies.push(SecretaryEnnemy.new(self, x, y))
            @blocks.push [x, y]
          # walls
          when Gosu::Color::BLACK
            @walls.push [x, y]
            @blocks.push [x, y]
          # invisible walls
          when Gosu::Color.new(255, 128, 128, 128)
            @blocks.push [x, y]
          end
          @tiles[y * @minimap.width + x] = tile
        end
      end
    end

    @models.each do |model|
      shape, x, z = *model
      if shape == :desk || shape == :desk2 || shape == :plant || shape == :coffee
        @tiles[convert_coords_to_index(x, z)] = 2
        @tiles[convert_coords_to_index(x+1, z)] = 2
        @blocks.push [x, z]
        @blocks.push [x+1, z]
      elsif shape == :fire_extinguisher || shape == :chair
        @tiles[convert_coords_to_index(x, z)] = 3
        @blocks.push [x, z]
      end
    end
  end

  def set_start_position(x, z)
    @start_position = [x, 0, z]
  end

  def get_start_position
    @start_position
  end

  def set_end_position(x, z)
    @end_position = [x, 0, z]
  end

  def get_end_position
    @end_position
  end

  def convert_index_to_coords(i)
    y = i / @minimap.width
    x = i % @minimap.width
    [x, y]
  end

  def coords_to_tile(x, z)
    [(x / @tile_size).floor, (z / @tile_size).floor]
  end

  def convert_coords_to_index(x, y)
    @minimap.width * y + x
  end

  def collides?(x, z)
    @blocks.include?([x, z])
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

  def update(hero_x, hero_z)
    @ennemies.each do|ennemy| 
      ennemy.update
      if ennemy.sees_hero?(hero_x, hero_z)
        @window.game_over
      end
    end
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
    @ennemies.each {|ennemy| ennemy.draw}
  end

  def draw_minimap(hero_x, hero_z)
    scale    = 5
    offset_x = 640 - scale * @minimap.width
    offset_y = 0

    # generates some MGS greenish like render
    @minimap_render ||= Gosu::render(@minimap.width, @minimap.height, retro: true) do 
      Gosu::draw_rect(0, 0, @minimap.width, @minimap.height, Gosu::Color.new(255, 1, 34, 23))
      @blocks.each {|block| Gosu::draw_rect(block[0], block[1], 1, 1, Gosu::Color.new(255, 0, 236, 0))}
    end

    hero_x = (hero_x / @tile_size).floor
    hero_z = (hero_z / @tile_size).floor
    @minimap_render.draw(offset_x, offset_y, 0, scale, scale, Gosu::Color.new(128, 255, 255, 255))
    Gosu::draw_rect(hero_x * scale + offset_x, hero_z * scale + offset_y, scale, scale, Gosu::Color::WHITE)

    @ennemies.each do |ennemy| 
      Gosu::draw_rect(ennemy.x * scale + offset_x, ennemy.z * scale + offset_y, scale, scale, Gosu::Color::RED)
    end
  end
end

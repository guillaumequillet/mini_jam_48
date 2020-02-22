class Ennemy
  attr_reader :x, :z, :angle
  def initialize(map, x, z)
    @map   = map
    @x, @z = x, z
    @angle = 0
  end
end


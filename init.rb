require 'gosu'
require 'opengl'
require 'glu'

OpenGL.load_lib
GLU.load_lib

include OpenGL, GLU

require_relative 'lib/utils.rb'
require_relative 'lib/obj_loader.rb'
require_relative 'lib/hero.rb'
require_relative 'lib/map.rb'
require_relative 'lib/camera.rb'
require_relative 'lib/window.rb'

Window.new.show

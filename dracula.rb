class Dracula
  attr_accessor :image, :vel_x, :vel_y, :angle, :x, :y, :spawn, :sprite_left, :sprite_right, :vision, :disappear_right, :disappear_left
  def initialize (x, y, vel_x, vel_y)
    @image = Gosu::Image.new("media/Dracula/idle1.png")
    @angle = 0.0

    @vel_x = vel_x
    @vel_y = vel_y
    @x = x
    @y = y

    #sprite animation
    @sprite_right = Gosu::Image.load_tiles("media/Dracula/Right.png", 188, 336)
    @sprite_left = Gosu::Image.load_tiles("media/Dracula/Left.png", 188, 336)

    @disappear_right = Gosu::Image.load_tiles("media/Dracula/disappear_right.png",332, 380)
    @disappear_left = Gosu::Image.load_tiles("media/Dracula/disappear_left.png",332, 380)

    #vision buff
    @vision = Gosu::Image.load_tiles("media/Buff/vision.png", 192, 192)

  end
end

def draw_dracula dracula
  dracula.image.draw_rot(dracula.x, dracula.y, ZOrder::DRACULA, dracula.angle, 0.5, 0.5, 0.35, 0.35)
end

def move(dracula, hero)
  dir_x = hero.x - dracula.x
  dir_y = hero.y - dracula.y
  distance = Math.sqrt(dir_x*dir_x + dir_y*dir_y)
  dir_x /= distance
  dir_y /= distance
  dracula.x += dracula.vel_x*dir_x 
  dracula.y += dracula.vel_y*dir_y
end

def spawn_dracula(mode)
  if rand(2) < 1
    x = rand * SCREEN_WIDTH
    y = 0
  else
    y = rand * SCREEN_HEIGHT
    x = 0
  end
  case mode
    when :easy 
      vel_x = rand(1 .. 2) * rand
      vel_y = rand(1 .. 2) * rand
    when :medium
      vel_x = rand(2 .. 3) * rand
      vel_y = rand(2 .. 3) * rand
    when :hard
      vel_x = rand(3 .. 4) * rand
      vel_y = rand(3 .. 4)  * rand
    end
  dracula = Dracula.new(x,y, vel_x, vel_y)
  dracula.image = (dracula.x < @hero.x) ? Gosu::Image.new("media/Dracula/idle2.png") : Gosu::Image.new("media/Dracula/idle1.png")
  dracula.spawn = Time.now
  return dracula
end

def dracula_sprite_left dracula
  dracula.image = dracula.sprite_left[Gosu.milliseconds / 120 % dracula.sprite_left.length]
end

def dracula_sprite_right dracula
  dracula.image = dracula.sprite_right[Gosu.milliseconds / 120 % dracula.sprite_right.length]
end

def invisible(dracula, hero)
  if dracula.x < hero.x 
    @disappear = dracula.disappear_right
    dracula.image = dracula.disappear_right[Gosu.milliseconds / 120 % dracula.disappear_right.length]
  else
     @disappear = dracula.disappear_left
    dracula.image = dracula.disappear_left[Gosu.milliseconds / 120 % dracula.disappear_left.length]
  end
end

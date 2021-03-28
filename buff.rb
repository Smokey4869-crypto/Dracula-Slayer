class Buff
  attr_accessor :x, :y, :image, :duration, :sound, :angle, :type
  def initialize(type)
    @x = rand(0.2..1) * SCREEN_WIDTH
    @y = rand(0.2..1) * SCREEN_HEIGHT
    @sound = Gosu::Song.new("media/Buff/popup.wav")
    @angle = 0.0
    @type = type
  end
end

def draw_buff buff, hero
  case buff.type
  when :shield
    buff.image = Gosu::Image.new("media/Buff/potion0.png")
  when :vision
    buff.image = Gosu::Image.new("media/Buff/potion1.png")
  when :heal
    buff.image = Gosu::Image.new("media/Buff/potion2.png")
  end
  #buff.image = potion[Gosu.milliseconds / 180 % potion.length]
  buff.image.draw_rot(buff.x, buff.y, ZOrder::DRACULA, buff.angle, 0.5, 0.5, 0.15, 0.15)
end

def spawn_buff
  case rand(3)
  when 0
    buff = Buff.new(:vision)
  when 1
    buff = Buff.new(:heal)
  when 2
    buff = Buff.new(:shield)
  end
  buff.sound.play
  return buff
end


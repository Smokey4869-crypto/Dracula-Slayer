MAX_HP = 5
class Hero
  attr_accessor :die, :score, :image, :buff, :vel_x, :vel_y, :angle, :x, :y, :slash, :status, :lives, :sprite_left, :sprite_right

  def initialize()
    @image = Gosu::Image.new("media/Hero/idle1.png")
    @slash = Gosu::Sample.new("media/Hero/slash.wav")
    @status = Gosu::Song.new("media/Buff/powerup.wav")
    @die = false
    @vel_x = @vel_y = 4.5
    @x = @y = @angle = 0.0
    @score = 0
    @left = true
    @lives = MAX_HP
    @buff = nil

    #sprite animation
    @sprite_right = Gosu::Image.load_tiles("media/Hero/Right.png", 205, 248)
    @sprite_left = Gosu::Image.load_tiles("media/Hero/Left.png", 205, 248)
  end
end

def warp(hero, x, y)
  hero.x, hero.y = x, y
end

def move_left hero
  if hero.x - hero.vel_y > 0
    hero.x -= hero.vel_x
    hero.x %= SCREEN_WIDTH
  end
end

def move_right hero
  if hero.x + hero.vel_x < SCREEN_WIDTH
    hero.x += hero.vel_x
    hero.x %= SCREEN_WIDTH
  end
end

def move_up hero
  if hero.y - hero.vel_y > 0
    hero.y -= hero.vel_y
    hero.y %= SCREEN_HEIGHT
  end
end

def move_down hero
  if hero.y + hero.vel_y < SCREEN_HEIGHT - 40
    hero.y += hero.vel_y
    hero.y %= SCREEN_HEIGHT
  end

end

def draw_hero hero
  if !hero.die
    hero.image.draw_rot(hero.x, hero.y, ZOrder::PLAYER, hero.angle, 0.5, 0.5, 0.5, 0.5)
  else
    die1 = Gosu::Image.load_tiles("media/Hero/die1.png", 311, 248)
    die2 = Gosu::Image.load_tiles("media/Hero/die2.png", 311, 248)
    die = (@left) ? die1 : die2
    image = die[Gosu.milliseconds / 120 % die.length]
    image.draw_rot(@hero.x, @hero.y, ZOrder::PLAYER, @hero.angle, 0.6, 0.45, 0.5, 0.5)
  end
end

def sprite_left(hero)
  hero.image = hero.sprite_left[Gosu.milliseconds / 120 % hero.sprite_left.length]
end

def sprite_right(hero)
  hero.image = hero.sprite_right[Gosu.milliseconds / 120 % hero.sprite_right.length]
end


def fight_dracula (draculas, hero)
  draculas.reject! do |dracula|
    if Gosu.distance(hero.x, hero.y, dracula.x, dracula.y) < 80
      if hero.buff == :shield
        hero.score += 1
        hero.slash.play
      else
        hero.lives -= 1
        Gosu::Song.new("media/Hero/hero_die.wav").play
        if hero.lives == 0
          hero.die = true
          @started = false
          hero.status = Gosu::Song.new("media/Hero/hero_die.wav")
          hero.status.play
        end
      end
      true
    else
      false
    end
  end
end


def get_buff(hero)
  #Buffs behaviors
  if hero.buff != nil
    if Gosu.milliseconds.div(1000) - @buff_start < @buff_time + 1
      if hero.buff == :shield 
        Gosu::Image.new("media/Buff/shield.png").draw_rot(hero.x, hero.y, ZOrder::PLAYER, hero.angle, 0.5, 0.5, 0.3, 0.3)
      elsif hero.buff == :vision
        @draculas.each do |dracula|
          if Gosu.distance(@hero.x, @hero.y, dracula.x, dracula.y) > 330
            dracula.image = dracula.vision[Gosu.milliseconds / 60 % dracula.vision.length]
            draw_dracula dracula
          end
        end
      elsif hero.buff == :heal
        healing = Gosu::Image.load_tiles("media/Buff/healing.png", 192, 192)
        image = healing[Gosu.milliseconds / 120 % healing.length]
        image.draw_rot(hero.x, hero.y, ZOrder::PLAYER, hero.angle, 0.5, 0.5, 0.8, 0.8)
        if hero.lives < MAX_HP and (Gosu.milliseconds.div(1000) - @buff_start).div(1) == @buff_time
          hero.lives += 1
          hero.buff = nil
          @pending_start = Gosu.milliseconds.div(1000)
        end
      end
    else
      hero.buff = nil
      @pending_start = Gosu.milliseconds.div(1000)
    end
  end
end


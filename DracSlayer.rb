=begin
  Author: Minh Nguyen
  Create Date: October 26, 2020
  Purpose: Custom Program for Intro to Programming COS10009
  Graphic References:
    https://www.gameart2d.com
    https://mrbubblewand.wordpress.com
    https://assetsdownload.com/
    https://itch.io/game-assets
  Audio References:
    https://freesound.org/
    http://soundbible.com/tags-vampire.html
    https://www.soundsnap.com/
=end


require 'rubygems'
require 'gosu'
require './hero'
require './dracula'
require './buff'
require './records'
require 'mysql2'

SCREEN_HEIGHT = 720
SCREEN_WIDTH = 1280
CHASE_TIME = 5

module ZOrder
  BACKGROUND, DRACULA, PLAYER, UI = *0..3
end


class DraculaSlayerGame < Gosu::Window
  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Dracula Slayer"
    #For enter name later
    #######

    @background = Gosu::Image.new("media/graveyard.png", :tileable => true)
    @started = false
    @recorded = false
    #Spell duration and waiting time
    @buff_start = 0
    @pending_start = Gosu.milliseconds.div(1000)

    @scream = Gosu::Song.new("media/Dracula/scream.wav")
    @draculas = Array.new
    @shades = Array.new
    @buffs = Array.new

    @hero = Hero.new()
    @font = Gosu::Font.new(20)
    warp(@hero, SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
  end


  def update
    if Gosu.button_down? Gosu::KB_LEFT or Gosu.button_down? Gosu::GP_LEFT
      move_left @hero
      @left = true
    end
    if Gosu.button_down? Gosu::KB_RIGHT or Gosu.button_down? Gosu::GP_RIGHT
      move_right @hero
      @left = false
    end
    if Gosu.button_down? Gosu::KB_UP or Gosu.button_down? Gosu::GP_BUTTON_0
      move_up @hero
    end
    if Gosu.button_down? Gosu::KB_DOWN or Gosu.button_down? Gosu::GP_BUTTON_9
      move_down @hero
    end

    if @started 
      if rand(200) == 0
        @scream.play(false)
      end

      #Generate draculas
      if rand(100) < 2 and @draculas.size < 7
        vamp = spawn_dracula(@mode)
        @draculas.push(vamp)
        @shades.push(vamp)
      end

      @shades.each do |shade|
        move(shade, @hero)
        if shade.x > 40 and shade.y > 40
          invisible(shade, @hero)
          remove_shade()
        end
      end

      @draculas.each do |dracula|
        move(dracula, @hero)
       remove_dracula
      end

      case @mode
      when :easy 
        @buff_time = 10
        @pending = 10
      when :medium
        @buff_time = 8
        @pending = 15
      when :hard
        @buff_time = 6
        @pending = 20
      end

      if @mode != nil
        if @pending - (Gosu.milliseconds.div(1000) - @pending_start).div(1) == 0 and @buffs.size < 1 and @hero.buff == nil
          @buffs.push(spawn_buff)
        end
      end
      fight_dracula(@draculas, @hero)
      remove_potion(@buffs, @hero)

      if @hero.die
        self.text_input = Gosu::TextInput.new
        self.text_input.text = "Please enter your name..."
      end
    else
      @pending_start = Gosu.milliseconds.div(1000)
    end

  end


def draw_UI
  @font.draw_text("Mode: #{@mode.upcase}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::GREEN)
  @font.draw_text("Score: #{@hero.score}", 10, 40, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  @font.draw_text("HP:", 10, 70, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  Gosu.draw_rect(50, 70, 40 * @hero.lives, 20, Gosu::Color::RED, ZOrder::UI, mode=:default)
  if @hero.buff != nil
    @font.draw_text("Spell duration: #{@buff_time - (Gosu.milliseconds.div(1000) - @buff_start).div(1)}", 10, 100, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  else
     @waiting = @pending - (Gosu.milliseconds.div(1000) - @pending_start).div(1)
    if @waiting >= 0
      @font.draw_text("Next spell in: #{@waiting}", 10, 100, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    else
      @font.draw_text("Spell appeared", 10, 100, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    end
  end
end

def draw_menu
  @font.draw_text("DRACULA SLAYER", SCREEN_WIDTH/3 + 30, SCREEN_HEIGHT/2 - 100, ZOrder::UI, 2.0, 2.0, Gosu::Color::RED)
  @font.draw_text("Play", SCREEN_WIDTH/3 + 30, SCREEN_HEIGHT/2 - 45, ZOrder::UI, 1.5, 1.5, Gosu::Color::YELLOW)
  if @select_mode
    @font.draw_text("Easy", SCREEN_WIDTH/3 + 100, SCREEN_HEIGHT/2 - 45, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLUE)
    @font.draw_text("Medium", SCREEN_WIDTH/3 + 170, SCREEN_HEIGHT/2 - 45, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLUE)
    @font.draw_text("Hard", SCREEN_WIDTH/3 + 275, SCREEN_HEIGHT/2 - 45, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLUE)
  end
  @font.draw_text("Records", SCREEN_WIDTH/3 + 30, SCREEN_HEIGHT/2, ZOrder::UI, 1.5, 1.5, Gosu::Color::YELLOW)
end

def enter_name
  @font.draw(self.text_input.text, SCREEN_WIDTH/3 + 30, SCREEN_HEIGHT/2 - 100, ZOrder::UI, 1.5, 1.5, Gosu::Color::RED)
end

  ##################
def draw
  #MAIN MENU
  if !@started and !@hero.die
    draw_menu
  end
  
  if @started
    @background.draw(0, 0, ZOrder::BACKGROUND)
    @font.draw_text("Back", SCREEN_WIDTH - 80, 20, ZOrder::UI, 1.5, 1.5, Gosu::Color::GREEN)
    draw_hero @hero
    get_buff(@hero) #draw different states of hero after getting buff

    #health bar and score
    draw_UI

    @buffs.each do |buff|
      draw_buff buff, @hero
    end

    @shades.each do |shade|
      draw_dracula(shade)
    end

    @draculas.each do |dracula|
      if Gosu.distance(@hero.x, @hero.y, dracula.x, dracula.y) < 330
        if dracula.x < @hero.x
          dracula_sprite_right dracula
        else
          dracula_sprite_left dracula
        end
        draw_dracula dracula
      end
    end

    #Sprite matching moves from KB
    if Gosu.button_down? Gosu::KB_LEFT or Gosu.button_down? Gosu::GP_LEFT
      sprite_left(@hero)
    elsif Gosu.button_down? Gosu::KB_RIGHT or Gosu.button_down? Gosu::GP_RIGHT
      sprite_right(@hero)
    elsif Gosu.button_down? Gosu::KB_DOWN or Gosu.button_down? Gosu::GP_BUTTON_9 or Gosu.button_down? Gosu::KB_UP or Gosu.button_down? Gosu::GP_BUTTON_0
      if @left
        sprite_left(@hero)
      else
        sprite_right(@hero)
      end
    else
      @hero.image = (@left) ? Gosu::Image.new("media/Hero/idle2.png") : Gosu::Image.new("media/Hero/idle1.png")
    end

    if Gosu.button_down? Gosu::KB_SPACE 
      attack = Gosu::Image.load_tiles("media/Hero/attack.png", 205, 248)
      @hero.image = attack[Gosu.milliseconds / 120 % attack.length]
    end
  end 

  if @hero.die and !@recorded
    enter_name
  end

  if @recorded 
    draw_records
    @font.draw_text("Back", SCREEN_WIDTH - 80, 20, ZOrder::UI, 1.5, 1.5, Gosu::Color::GREEN)
  end

end

  
  def remove_shade()
    @shades.reject! do |shade|
      if shade.image == @disappear[@disappear.length-1] or Gosu.distance(shade.x, shade.y, @hero.x, @hero.y) < 330
        true
      else
        false
      end
    end
  end

  def remove_dracula
    @draculas.reject! do |dracula|
      if Time.now - dracula.spawn > 9 * CHASE_TIME
        true
      else
        false
      end
    end
  end

  def remove_potion(buffs, hero)
    buffs.reject! do |buff|
      if Gosu.distance(hero.x, hero.y, buff.x, buff.y) < 80
        if !hero.die
          hero.buff = buff.type
          hero.status.play
          @buff_start = Gosu.milliseconds.div(1000)
          true
        else
          false
        end
      end
    end
end

  def needs_cursor?; true; end

  def area_clicked(leftX, topY, rightX, bottomY)
     # complete this code
     if (mouse_x > leftX and mouse_x < rightX) and (mouse_y > topY and mouse_y < bottomY)
       true
     else
       false
     end
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    end

    if id == Gosu::MsLeft
      if area_clicked(SCREEN_WIDTH/3 + 30, SCREEN_HEIGHT/2 - 50, SCREEN_WIDTH/2 + 100, SCREEN_HEIGHT/2 - 20)
        @select_mode = true
        if area_clicked(SCREEN_WIDTH/3 + 100, SCREEN_HEIGHT/2 - 45, SCREEN_WIDTH/3 + 130, SCREEN_HEIGHT/2 - 15)
          @mode = :easy
          @started = true
        elsif area_clicked(SCREEN_WIDTH/3 + 170, SCREEN_HEIGHT/2 - 45, SCREEN_WIDTH/3 + 220, SCREEN_HEIGHT/2 - 15)
          @mode = :medium
          @started = true
        elsif area_clicked(SCREEN_WIDTH/3 + 275, SCREEN_HEIGHT/2 - 45, SCREEN_WIDTH/3 + 310, SCREEN_HEIGHT/2 - 15)
          @mode = :hard
          @started = true
        end   
      end

      if area_clicked(SCREEN_WIDTH/3 + 30, SCREEN_HEIGHT/2, SCREEN_WIDTH/3 + 110, SCREEN_HEIGHT/2 + 40)
        @recorded = true
        @hero.die = true
      end

      if area_clicked(SCREEN_WIDTH - 80, 20, SCREEN_WIDTH - 10, 45)
        @started = false
        @hero.die = false
        @recorded = false
      end
    end

    if @hero.die 
      if id == Gosu::KB_SPACE
        @player_name = self.text_input.text
        @date = Time.now
        @recorded = true
        insert_records
      end
    end
  end

end

DraculaSlayerGame.new.show if __FILE__ == $0
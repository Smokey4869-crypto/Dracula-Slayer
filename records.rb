#scores are recorded in my personal database at Swinburne University
def settings
  client = Mysql2::Client.new(
  username: "s103137309",
  password: "vaticancameos4869",
  host: "feenix-mariadb.swin.edu.au",
  database: "s103137309_db"
  )
  return client
end

def draw_records
  client = settings
  if !client 
    puts "Database connection failed"
    @font.draw_text("Database connection failed", 10, 10, ZOrder::UI, 1.5, 1.5, Gosu::Color::RED)
  else
    sql_table = "turns"
    sql_string = "SELECT * FROM #{sql_table}"
    result = client.query(sql_string)
    draw_table(result)
  end
end

def draw_table(result)
  @font.draw_text("LEADERBOARDS", 20, 20, ZOrder::UI, 1.5, 1.5, Gosu::Color::GREEN)
  @font.draw_text("ID", 20, 85, ZOrder::UI, 1.5, 1.5, Gosu::Color::GREEN)
  @font.draw_text("Name", 20 + SCREEN_WIDTH/4, 85, ZOrder::UI, 1.5, 1.5, Gosu::Color::GREEN)
  @font.draw_text("Score", 20 + 2 * SCREEN_WIDTH/4, 85, ZOrder::UI, 1.5, 1.5, Gosu::Color::GREEN)
  @font.draw_text("Date and Time", 20 + 3*SCREEN_WIDTH/4, 85, ZOrder::UI, 1.5, 1.5, Gosu::Color::GREEN)
  Gosu.draw_line(20, 125, Gosu::Color::WHITE, SCREEN_WIDTH - 40, 125, Gosu::Color::WHITE, ZOrder::UI)

  result.each do |row|
    line_pos = 150 + (row["ID"]-1)*40
    @font.draw_text(row["ID"], 20, line_pos , ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    @font.draw_text(row["Name"], 20 + SCREEN_WIDTH/4, line_pos, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    @font.draw_text(row["Score"], 20 + 2 * SCREEN_WIDTH/4, line_pos, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    @font.draw_text(row["Date_and_Time"], 20 + 3*SCREEN_WIDTH/4, line_pos, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  end
end

def insert_records
  client = settings
  if !client 
    puts "Database connection failed"
    @font.draw_text("Database connection failed", 10, 10, ZOrder::UI, 1.5, 1.5, Gosu::Color::RED)
  else
    sql_table = "turns"
    sql_string = "INSERT INTO #{sql_table} (Name, Score, Date_and_Time) VALUES ('#{@player_name}', '#{@hero.score}','#{@date}')"
    result2 = client.query(sql_string)
  end
end

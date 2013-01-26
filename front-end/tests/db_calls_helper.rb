module DbCallsHelper
  def count_users
    Integer(@pg.exec("SELECT COUNT(*) FROM users").first['count'])
  end

  def get_user(oauth_id)
    User.new(@pg.exec("SELECT * FROM users WHERE oauth_id = $1", [oauth_id]).first)
  end

  def count_links(url = nil)
    if url
      Integer(@pg.exec("SELECT COUNT(*) FROM links WHERE url = $1", [url]).first['count'])
    else
      Integer(@pg.exec("SELECT COUNT(*) FROM links").first['count'])
    end
    
  end

  def count_bookmarks(user_id = nil)
    if user_id
      Integer(@pg.exec("SELECT COUNT(*) FROM bookmarks WHERE user_id = $1", [user_id]).first['count'])  
    else
      Integer(@pg.exec("SELECT COUNT(*) FROM bookmarks").first['count'])  
    end
    
  end

  def get_bookmark(user_id, url)
    q = <<-EOS
      SELECT b.id, l.url, l.title, b.added_on, b.name, b.notes, b.is_pinned 
      FROM bookmarks b, links l
      WHERE b.link_id = l.id
      AND b.user_id = $1
      AND l.url = $2
    EOS
    Bookmark.new(@pg.exec(q, [user_id, url]).first)
  end

  def get_link_title(url)
    q = <<-EOS
      SELECT title FROM links
      WHERE url = $1
    EOS
    @pg.exec(q, [url]).first['title'] 
  end

  def delete_link(url)
    q1 = <<-EOS
      DELETE FROM bookmarks WHERE link_id = 
        (SELECT id FROM links WHERE url = $1)
    EOS
    q2 = "DELETE FROM links WHERE url = $1"
    [q1, q2].each { |q| @pg.exec(q, [url]) }
  end

  def delete_bookmark(user_id, url)
    q = <<-EOS
      DELETE FROM bookmarks WHERE user_id = $1 AND link_id =
        (SELECT id FROM links WHERE url = $2)
    EOS
    @pg.exec(q, [user_id, url])
  end

  def delete_user(oauth_id)
    q1 = <<-EOS
      DELETE FROM bookmarks WHERE user_id = 
        (SELECT id FROM users WHERE oauth_id = $1)
    EOS
    q2 = "DELETE FROM users WHERE oauth_id = $1"
    [q1, q2].each { |q| @pg.exec(q, [oauth_id]) }
  end

end
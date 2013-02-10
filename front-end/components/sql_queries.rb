module SqlQueries
  GET_USR = "SELECT * FROM users WHERE oauth_id = $1 AND name = $2"
  
  INS_USR = <<-EOS
    INSERT INTO users (oauth_id, access_token, token_expiry, name, created_at, last_activity_at)
    VALUES($1, $2, $3, $4, $5, $6)
  EOS

  CHK_USR = "SELECT * FROM users WHERE oauth_id = $1"

  GET_BMS = <<-EOS
    SELECT b.id, l.url, l.title, b.added_on, b.name, b.notes, b.is_pinned 
    FROM bookmarks b, links l 
    WHERE b.link_id = l.id 
    AND b.user_id = $1
    ORDER BY b.added_on DESC
  EOS
  
  GET_FDS = <<-EOS
    SELECT f.id, l.url, l.title, f.description, f.web_url
    FROM  feeds f, links l
    WHERE f.link_id = l.id
    AND f.user_id = $1
    ORDER BY f.added_on DESC 
  EOS

  CHK_BM = <<-EOS
    SELECT b.id, l.url, l.title, b.added_on, b.name, b.notes, b.is_pinned 
    FROM bookmarks b, links l
    WHERE b.user_id = $1
    AND b.link_id = l.id
    AND l.url = $2
  EOS

  CHK_LN = "SELECT id FROM links WHERE url = $1"

  INS_LN = "INSERT INTO links (url, title, icon) VALUES ($1, $2, $3) RETURNING id"

  INS_BM = <<-EOS
    INSERT INTO bookmarks (name, added_on, is_pinned, user_id, link_id)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING id
  EOS

  GET_BM = <<-EOS
    SELECT b.id, l.url, l.title, b.added_on, b.name, b.notes, b.is_pinned
    FROM bookmarks b, links l
    WHERE b.link_id = l.id
    AND b.id = $1
    AND b.user_id = $2
  EOS

  GET_LN = "SELECT * FROM links WHERE id = $1"

  EDIT_BM = <<-EOS 
    UPDATE bookmarks SET name = $1, notes = $2, is_pinned = $3
    WHERE id = $4
  EOS

  GET_PINNED = <<-EOS
    SELECT b.id, l.url, l.title, b.added_on, b.name, b.notes, b.is_pinned
    FROM bookmarks b, links l
    WHERE b.link_id = l.id
    AND b.is_pinned = TRUE
    AND b.user_id = $1
  EOS
    
  DEL_BM = "DELETE FROM bookmarks WHERE user_id = $1 AND id = $2"

end
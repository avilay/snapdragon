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

  CHK_BM = <<-EOS
    SELECT b.id, l.url, l.title, b.added_on, b.name, b.notes, b.is_pinned 
    FROM bookmarks b, links l
    WHERE b.user_id = $1
    AND b.link_id = l.id
    AND l.url = $2
  EOS

  CHK_LN = "SELECT id FROM links WHERE url = $1"

  INS_LN = "INSERT INTO links (url, title) VALUES ($1, $2) RETURNING id"

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

  GET_PINNED_BMS = <<-EOS
    SELECT b.id, l.url, l.title, b.added_on, b.name, b.notes, b.is_pinned
    FROM bookmarks b, links l
    WHERE b.link_id = l.id
    AND b.is_pinned = TRUE
    AND b.user_id = $1
  EOS
    
  DEL_BM = "DELETE FROM bookmarks WHERE user_id = $1 AND id = $2"

  CHK_USR_FD = "SELECT * FROM users_feeds WHERE user_id = $1 AND feed_id = $2"

  CHK_FD = "SELECT * FROM feeds WHERE feed_url = $1"  

  INS_USR_FD = <<-EOS
    INSERT INTO users_feeds (user_id, feed_id, added_on, is_pinned)
    VALUES ($1, $2, $3, $4)
  EOS

  INS_FD = <<-EOS
    INSERT INTO feeds (feed_url, web_url, title, description, last_updated_on)
    VALUES ($1, $2, $3, $4, $5)
  EOS

  GET_FD_FOR_USR = <<-EOS
    SELECT f.id, f.feed_url, f.web_url, f.title, f.description, f.last_updated_on, f.crawled_at, uf.added_on, uf.is_pinned
    FROM feeds f, users_feeds uf
    WHERE f.id = uf.feed_id
    AND uf.user_id = $1
    AND f.id = $2
  EOS

  GET_FDS_FOR_USR = <<-EOS
    SELECT f.id, f.feed_url, f.web_url, f.title, f.description, f.last_updated_on, f.crawled_at, uf.added_on, uf.is_pinned
    FROM feeds f, users_feeds uf
    WHERE f.id = uf.feed_id
    AND uf.user_id = $1    
  EOS

  DEL_FD = "DELETE FROM feeds WHERE user_id = $1 AND id = $2"

  # INS_FD = <<-EOS
  #   INSERT INTO feeds (description, last_updated_on, added_on, is_pinned, user_id, link_id, web_url)
  #   VALUES ($1, $2, $3, $4, $5, $6, $7)
  #   RETURNING id
  # EOS

  # CHK_FD = <<-EOS
  #   SELECT f.id, l.url, l.title, f.web_url, f.description, f.last_updated_on, f.added_on
  #   FROM feeds f, links l
  #   WHERE f.user_id = $1
  #   AND f.link_id = l.id
  #   AND l.url = $2
  # EOS

  # GET_FDS = <<-EOS
  #   SELECT f.id, l.url, l.title, f.web_url, f.description, f.last_updated_on, f.added_on
  #   FROM  feeds f, links l
  #   WHERE f.link_id = l.id
  #   AND f.user_id = $1
  #   ORDER BY f.added_on DESC 
  # EOS

  # GET_FD = <<-EOS
  #   SELECT f.id, l.url, l.title, f.web_url, f.description, f.last_updated_on, f.added_on
  #   FROM feeds f, links l
  #   WHERE f.link_id = l.id
  #   AND f.id = $1
  #   AND f.user_id = $2
  # EOS

  # GET_PINNED_FDS = <<-EOS
  #   SELECT f.id, l.url, l.title, f.web_url, f.description, f.last_updated_on, f.added_on
  #   FROM feeds f, links l
  #   WHERE f.link_id = l.id
  #   AND f.is_pinned = TRUE
  #   AND f.user_id = $1
  # EOS

  # EDIT_FD = <<-EOS
  #   UPDATE feeds SET description = $1, is_pinned = $2
  #   WHERE id = $3
  # EOS

  
end
require 'pg'
require 'csv'
require 'feedzirra'

bmcsv = File.expand_path(File.dirname(__FILE__) + "/test_bookmarks.csv")
uscsv = File.expand_path(File.dirname(__FILE__) + "/test_users.csv")
fdcsv = File.expand_path(File.dirname(__FILE__) + "/test_feeds.csv")

pg = PG.connect(dbname: 'snapdragon')

us = <<-EOS
  INSERT INTO users (oauth_id, access_token, token_expiry, name, created_at, last_activity_at)
  VALUES ($1, $2, $3, $4, $5, $6)
EOS
CSV.foreach(uscsv, headers: true) do |r|
  pg.exec(us, [r['oauth_id'], r['access_token'], r['token_expiry'], r['name'], r['created_at'], r['last_activity_at']])
end


ln = 'INSERT INTO links (url, title) VALUES ($1, $2) RETURNING id'
bm = "INSERT INTO bookmarks (name, notes, added_on, is_pinned, user_id, link_id) VALUES ($1, $2, $3, $4, $5, $6)"

pinned = [true, false]
lines = CSV.readlines(bmcsv, headers: true)
uids = pg.exec("SELECT id FROM users")
ctr = 0
lines.each do |r|
  ctr += 1
  lid = Integer(pg.exec(ln, [r['url'], r['title']]).first['id'])
  added_on = Time.now - rand(30*24*60*60) # Anytime in the last 1 month
  is_pinned = pinned[rand(2)]
  if ctr < 15
    uid = uids[0]['id']
  else
    uid = uids[1]['id']
  end
  pg.exec(bm, [r['name'], r['notes'], added_on, is_pinned, uid, lid])
end

fd = "INSERT INTO feeds (description, web_url, user_id, link_id, added_on) VALUES ($1, $2, $3, $4, $5)"
uid = uids[0]
CSV.foreach(fdcsv, headers: true) do |r|
  begin
    feed = Feedzirra::Feed.fetch_and_parse(r['url'])
    if feed
      lid = Integer(pg.exec(ln, [r['url'], feed.title]).first['id'])
      added_on = Time.now - rand(30*24*60*60) # Anytime in the last 1 month
      pg.exec(fd, [feed.description, feed.url, uid, lid, added_on])
    end
  rescue
    puts "Could not add feed #{r.inspect}"
  end
end
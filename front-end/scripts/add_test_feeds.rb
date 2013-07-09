require 'pg'
require 'csv'

fdcsv = File.expand_path(File.dirname(__FILE__) + "/test_feeds.csv")
pg = PG.connect(dbname: 'snapdragon')

ln = 'INSERT INTO links (url, title) VALUES ($1, $2) RETURNING id'
fd = <<-EOS
  INSERT INTO feeds (description, added_on, last_updated_on, is_pinned, link_id, web_url) 
  VALUES ($1, $2, $3, $4, $5, $6)
EOS
usfd = "INSERT INTO users_feeds (user_id, feed_id) VALUES ($1, $2)"
pinned = [true, false]

def add_feed_for_user(uid, row)
  lid = Integer($pg.exec($ln, [row['url'], row['title']]).first['id'])
  added_on = Time.now - rand(30*24*60*60) # Anytime in the last 1 month
  last_updated_on = Time.now - rand(30*24*60*60) # Anytime in the last 1 month
  is_pinned = $pinned[rand(2)]
  $pg.exec($fd, [row['description'], added_on, last_updated_on, is_pinned, uid, lid, row['web_url']])
end

lines = CSV.readlines(fdcsv, headers: true)
lines.each do |r|
  lid = Integer(pg.exec(ln, [r['url'], r['title']]).first['id'])
  added_on = Time.now - rand(30*24*60*60) # Anytime in the last 1 month
  last_updated_on = added_on
  is_pinned = pinned[rand(2)]
  pg.exec(fd, [r['description'], added_on, last_updated_on, is_pinned, lid, r['web_url']])
end

#half the items belong to both user 1 and user 2
#and all the items belong to user 1
uids = pg.exec("SELECT id FROM users")
fids = pg.exec("SELECT id FROM feeds")
mid = fids.count/2
(0..mid).each do |i|
  pg.exec(usfd, [uids[0]['id'], fids[i]['id']])
  pg.exec(usfd, [uids[1]['id'], fids[i]['id']])
end

(mid+1..fids.count-1).each do |i|
  pg.exec(usfd, [uids[0]['id'], fids[i]['id']])
end

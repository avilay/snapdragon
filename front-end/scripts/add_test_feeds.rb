require 'pg'
require 'csv'

fdcsv = File.expand_path(File.dirname(__FILE__) + "/test_feeds.csv")
pg = PG.connect(dbname: 'snapdragon')

fd = <<-EOS
  INSERT INTO feeds (feed_url, web_url, title, description, crawled_at, last_updated_on) 
  VALUES ($1, $2, $3, $4, $5, $6)
EOS
usfd = "INSERT INTO users_feeds (user_id, feed_id, added_on, is_pinned) VALUES ($1, $2, $3, $4)"
pinned = [true, false]

lines = CSV.readlines(fdcsv, headers: true)
lines.each do |r|
  last_updated_on = Time.now - rand(30*24*60*60) # Anytime in the last 1 month
  crawled_at = nil
  pg.exec(fd, [r['feed_url'], r['web_url'], r['title'], r['description'], crawled_at, last_updated_on])
end

#half the items belong to both user 1 and user 2
#and all the items belong to user 1
uids = pg.exec("SELECT id FROM users")
fids = pg.exec("SELECT id FROM feeds")
mid = fids.count/2
(0..mid).each do |i|
  added_on = Time.now - rand(30*24*60*60) # Anytime in the last 1 month
  is_pinned = pinned[rand(2)]
  pg.exec(usfd, [uids[0]['id'], fids[i]['id'], added_on, is_pinned])
  pg.exec(usfd, [uids[1]['id'], fids[i]['id'], added_on, is_pinned])
end

(mid+1..fids.count-1).each do |i|
  added_on = Time.now - rand(30*24*60*60) # Anytime in the last 1 month
  is_pinned = pinned[rand(2)]
  pg.exec(usfd, [uids[0]['id'], fids[i]['id'], added_on, is_pinned])
end

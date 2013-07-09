require 'pg'
require 'csv'

bmcsv = File.expand_path(File.dirname(__FILE__) + "/test_bookmarks.csv")
pg = PG.connect(dbname: 'snapdragon')

ln = 'INSERT INTO links (url, title) VALUES ($1, $2) RETURNING id'
bm = "INSERT INTO bookmarks (name, notes, added_on, is_pinned, user_id, link_id) VALUES ($1, $2, $3, $4, $5, $6)"
pinned = [true, false]

uids = pg.exec("SELECT id FROM users")

lines = CSV.readlines(bmcsv, headers: true)
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



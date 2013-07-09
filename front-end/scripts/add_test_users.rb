require 'pg'
require 'csv'

uscsv = File.expand_path(File.dirname(__FILE__) + "/test_users.csv")
pg = PG.connect(dbname: 'snapdragon')
us = <<-EOS
  INSERT INTO users (oauth_id, access_token, token_expiry, name, created_at, last_activity_at)
  VALUES ($1, $2, $3, $4, $5, $6)
EOS

CSV.foreach(uscsv, headers: true) do |r|
  pg.exec(us, [r['oauth_id'], r['access_token'], r['token_expiry'], r['name'], r['created_at'], r['last_activity_at']])
end
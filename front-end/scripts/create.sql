CREATE TABLE IF NOT EXISTS users (
	id serial CONSTRAINT U_pri_key PRIMARY KEY,
	oauth_id varchar(512),
	access_token varchar(1024),
	token_expiry timestamp,
	name varchar(50),	
	created_at timestamp,
	last_activity_at timestamp
);

CREATE TABLE IF NOT EXISTS links (
	id serial CONSTRAINT w_pri_key PRIMARY KEY,
	url varchar(1024),
	title varchar(1024),
	crawled_at timestamp
);

CREATE TABLE IF NOT EXISTS bookmarks (
	id serial CONSTRAINT b_pri_key PRIMARY KEY,
	name varchar(1024),
	notes text,
	added_on timestamp,
	is_pinned boolean,
	user_id integer CONSTRAINT fk_bookmarks_users REFERENCES users,
	link_id integer CONSTRAINT fk_bookmarks_links REFERENCES links
);

CREATE TABLE IF NOT EXISTS feeds (
	id serial CONSTRAINT f_pri_key PRIMARY KEY,
	description text,
  web_url varchar(1024),
  added_on timestamp,
	user_id integer CONSTRAINT fk_feeds_users REFERENCES users,
	link_id integer CONSTRAINT fk_feeds_links REFERENCES links
);
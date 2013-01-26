require_relative 'set_path'

class DataStoreTest < Test::Unit::TestCase
  include DbCallsHelper

  def setup
    @pg = PG.connect(dbname: 'snapdragon')    
    @ds = DataStore.new($conn_str)
  end

  # Ask for an existing user
  # No new user should be created, valid user returned
  def test_get_existing_user  
    num_users0 = count_users
    proto = User.new('oauth_id' => '566213105', 'name' => 'Avilay Parekh')    
    user = get_user('566213105')
    assert(user === @ds.add_or_get_user(proto))
    assert_equal(num_users0, count_users)
    assert_equal(user.id, @ds.user_id)
  end

  # Ask for a non-existing user
  # - oauth id exists in the db
  # - but is paired with a different name
  # No new user should be created, exception should be raised
  def test_get_mixedup_user
    proto = User.new('oauth_id' => '566213105', 'name' => 'Avilay Parekh')    
    num_users0 = count_users
    proto.name = 'I An Other'
    assert_raises(RuntimeError) { @ds.add_or_get_user(proto) }
    assert_equal(num_users0, count_users)
    assert_nil(@ds.user_id)    
    proto.name = 'Avilay Parekh'
  end

  # Ask for an non-existing user
  # - oauth id does not exist in the db,
  # - name is in the db with a different oauth id
  # New user with the new oauth id should be created    
  def test_add_mixedup_user
    num_users0 = count_users
    proto = User.new('oauth_id' => '566213105', 'name' => 'Avilay Parekh')
    proto.oauth_id = SecureRandom.uuid
    new_user = @ds.add_or_get_user(proto)
    user = get_user(proto.oauth_id)
    assert(user === new_user)
    assert_equal(num_users0 + 1, count_users)
    assert_equal(user.id, @ds.user_id)
    delete_user(user.oauth_id)
  end

  # Ask for a non-existing user
  # - oauth id does not exist in the db
  # - name does not exist in the db
  # New user should be created
  def test_add_user
    num_users0 = count_users
    proto = User.new('oauth_id' => SecureRandom.uuid, 'name' => 'Test User')    
    new_user = @ds.add_or_get_user(proto)
    user = get_user(proto.oauth_id)
    assert(user === new_user)
    assert_equal(num_users0 + 1, count_users)
    assert_equal(user.id, @ds.user_id)
    delete_user(user.oauth_id)
  end

  # Add a link that is already in the system
  def test_get_link
    num_links0 = count_links
    @ds.add_or_get_link('http://www.ml-class.com/')    
    assert_equal(num_links0, count_links)
  end

  # Add a link that is not in the system but is a valid HTTP url
  def test_add_link
    num_links0 = count_links
    test_link = 'http://news.ycombinator.com/'
    @ds.add_or_get_link(test_link)
    assert_equal(num_links0 + 1, count_links)
    assert_equal(1, count_links(test_link))
    assert_equal('Hacker News', get_link_title(test_link))
    delete_link(test_link)
  end

  # Add a link that is a valid URL but is not reachable over the Internet
  def test_add_pvt_link
    num_links0 = count_links
    test_link = 'http://www.avilayparekh.com/'
    @ds.add_or_get_link(test_link)
    assert_equal(num_links0 + 1, count_links)
    assert_equal(1, count_links(test_link))
    assert_empty(get_link_title(test_link))
    delete_link(test_link)
  end

end
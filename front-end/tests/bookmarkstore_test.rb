require_relative 'set_path'

class BookmarkStoreTest < Test::Unit::TestCase
  include DbCallsHelper

  def setup
    @pg = PG.connect(dbname: 'snapdragon')
    @bs = BookmarkStore.new($conn_str)
    @bs.add_or_get_user(User.new('oauth_id' => '566213105', 'name' => 'Avilay Parekh'))
  end

  # Get bookmarks without setting a user in data store
  def test_get_bookmarks_nouser
    ds = BookmarkStore.new($conn_str)
    assert_raises(RuntimeError) { ds.get_bookmarks }
  end

  # Get bookmarks for a valid user  
  def test_get_bookmarks
    exp_num_bms = count_bookmarks(1)
    act_num_bms = @bs.get_bookmarks.count
    assert_equal(exp_num_bms, act_num_bms)    
  end

  # Add a bookmark that the user already has
  # No new bookmarks should be created    
  def test_get_existing_bookmark
    test_url = 'http://www.ml-class.com/'
    num0 = count_bookmarks(@bs.user_id)
    tot0 = count_bookmarks
    assert(get_bookmark(@bs.user_id, test_url) === @bs.add_or_get_bookmark(test_url))
    assert_equal(num0, count_bookmarks(@bs.user_id))
    assert_equal(tot0, count_bookmarks)
  end

  # Add a new bookmark that is in the system but not for this user
  # A new bookmark should be created, but no new links
  # The new bookmark will have the same name as the title of the link    
  def test_add_bookmark
    test_url = 'http://www.gridgain.com/'
    num_lns0 = count_links
    num_bms0 = count_bookmarks
    act_bm = @bs.add_or_get_bookmark(test_url)
    exp_bm = get_bookmark(@bs.user_id, test_url)
    assert(exp_bm === act_bm)
    assert_equal(num_bms0 + 1, count_bookmarks)
    assert_equal(num_lns0, count_links)
    assert(get_link_title(test_url), exp_bm.name)
    delete_bookmark(@bs.user_id, test_url)
  end

  # Add a new bookmark that is not in the system
  # A new link should be created along with a new bookmark
  # The bookmark name and link title should be the page title
  def test_add_new_bookmark
    test_url = 'http://gigaom.com'
    title = 'GigaOM'
    num_lns0 = count_links
    tot_bms0 = count_bookmarks
    num_bms0 = count_bookmarks(@bs.user_id)
    act_bm = @bs.add_or_get_bookmark(test_url)
    exp_bm = get_bookmark(@bs.user_id, test_url)
    assert(exp_bm === act_bm)
    assert_equal(num_lns0 + 1, count_links)
    assert_equal(tot_bms0 + 1, count_bookmarks)
    assert_equal(num_bms0 + 1, count_bookmarks(@bs.user_id))
    assert_equal(get_link_title(test_url), exp_bm.name)
    delete_link(test_url)
  end

  # Add a new bookmark that is not a valid URI
  # No new bookmarks or links should be created
  def test_add_invalid_bookmark
    num_lns0 = count_links
    act_bm = @bs.add_or_get_bookmark('ha ha ha')
    assert(act_bm.errors.count > 0)
    assert_equal(num_lns0, count_links)
  end

  # Add a new bookmark that is a valid URI but is not reachable over the Internet
  # A new link should be created along with a new bookmark
  # Both the link title and the bookmark name should be an empty string  
  def test_add_pvt_bookmark
    test_url = 'http://www.avilayparekh.com/'
    num_lns0 = count_links
    num_bms0 = count_bookmarks
    act_bm = @bs.add_or_get_bookmark(test_url)
    exp_bm = get_bookmark(@bs.user_id, test_url)
    assert(exp_bm === act_bm)
    assert_equal(num_lns0 + 1, count_links)
    assert_equal(num_bms0 + 1, count_bookmarks)
    assert_empty(get_link_title(test_url))
    assert_empty(exp_bm.name)
    delete_link(test_url)
  end

  # Update a valid bookmark - name, notes, is_pinned
  def test_update_bookmark    
    bm0 = get_bookmark(@bs.user_id, 'http://www.ml-class.com/')
    new_name = SecureRandom.uuid.to_s
    bm0.name = new_name
    bm0.is_pinned = true
    new_notes = SecureRandom.uuid.to_s
    bm0.notes = new_notes
    new_bm = @bs.update_bookmark(bm0)
    assert(bm0 === new_bm, 'Updated bookmark does not match prototype')
    bm1 = get_bookmark(@bs.user_id, 'http://www.ml-class.com/')
    assert(bm1 === bm0, 'Before and after db dookmarks do not match')
  end

  # Try to update a bookmark that does not exist
  def test_update_nonexisting_bookmark
    bm0 = Bookmark.new('id' => 1000, 
        'url' => '/some/url', 
        'title' => 'some title')
    new_bm = @bs.update_bookmark(bm0)
    assert(new_bm.errors.count > 0)
  end

  # Try to update a bookmark that exists but the user does not own
  def test_update_unauth_bookmark
    bm0 = get_bookmark(2, 'http://www.gridgain.com/')
    bm0.name = 'hahaha'
    new_bm = @bs.update_bookmark(bm0)
    assert(new_bm.errors.count > 0)    
  end  

  # Get a valid bookmark that this user owns
  def test_get_bookmark
    exp_bm = get_bookmark(@bs.user_id, 'http://www.ml-class.com/')
    act_bm = @bs.get_bookmark(4)
    assert(exp_bm === act_bm)
  end

  # Get a valid bookmark that this user does not own
  def test_get_unauth_bookmark
    bm = @bs.get_bookmark(15)
    assert(bm.errors.count > 0)
  end

  # Get a bookmark that does not exist
  def test_get_nonexisting_bookmark
    bm = @bs.get_bookmark(15000)
    assert(bm.errors.count > 0)
  end

end
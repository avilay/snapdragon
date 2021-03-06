#$: << File.expand_path("/home/avilay/projects/snapdragon/front-end/components/")
#$: << File.expand_path("/home/avilay/projects/snapdragon/front-end/models/")
$: << File.expand_path("#{ENV['SD_HOME']}/front-end/components/")
$: << File.expand_path("#{ENV['SD_HOME']}/front-end/models/")

require 'test/unit'
require 'pg'
require 'data_store'
require 'bookmark_store'
require 'securerandom'
require_relative 'db_calls_helper'

$conn_str = %r{DATABASE_URL=(.*?)\s}.match(IO.read(".env"))[1]
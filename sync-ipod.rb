require_relative 'lib/ipod_db'

root = ARGV[0] || 'test_data'
db = IpodDB.new root

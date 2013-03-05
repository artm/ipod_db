#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'ipod_db'

root = ARGV[0] || 'test_data'
db = IpodDB.new root

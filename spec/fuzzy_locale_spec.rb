# encoding: UTF-8
require 'spec_helper'
require 'fuzzy_locale'
require 'ipod_db'

describe 'sanitize_filename()' do
  before {
    I18n.locale = :fuzzy
  }
  it 'transliterates russian' do
    IpodDB::sanitize_filename('русский').must_be :==, "russkij"
  end
  it 'transliterates RUSSIAN' do
    IpodDB::sanitize_filename('РУССКИЙ').must_be :==, "RUSSKIJ"
  end
  it 'transliterates german' do
    IpodDB::sanitize_filename('ümlaut').must_be :==, "umlaut"
  end
end


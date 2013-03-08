require 'minitest/autorun'
require 'purdytest'
$LOAD_PATH.push "File.dirname(__FILE__)/../lib"

module MiniTest::Assertions
  def assert_includes_each_of expected, sequence
    expected.each {|x| assert_includes sequence, x}
  end
  def assert_includes_none_of expected, sequence
    expected.each {|x| refute_includes sequence, x}
  end
end

Object.infect_an_assertion :assert_includes_each_of, :must_include_each_of
Object.infect_an_assertion :assert_includes_none_of, :must_include_none_of

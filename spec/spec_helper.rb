require 'minitest/autorun'
require "minitest/reporters"
MiniTest::Reporters.use!  [
  MiniTest::Reporters::DefaultReporter.new,
  MiniTest::Reporters::GuardReporter.new,
]
$LOAD_PATH.push "File.dirname(__FILE__)/../lib"
require 'bindata'

class Hash
  def is_subset_of? other
    all? { |key,value| other[key] == value }
  end
end

module MiniTest::Assertions
  def assert_includes_each_of expected, sequence
    expected.each {|x| assert_includes sequence, x}
  end
  def assert_includes_none_of expected, sequence
    expected.each {|x| refute_includes sequence, x}
  end
  def assert_is_subset_of superset, subset
    assert subset.is_subset_of?(superset), "Expected\n  #{subset}\n\nto be subset of\n  #{superset}"
  end
  def assert_records_are_like expected, actual
    actual.each_with_index do |record,i|
      h = Map.new record.snapshot
      h.delete :reclen
      h.must_be_subset_of expected[i]
    end
  end
end

Object.infect_an_assertion :assert_includes_each_of, :must_include_each_of
Object.infect_an_assertion :assert_includes_none_of, :must_include_none_of
Object.infect_an_assertion :assert_is_subset_of, :must_be_subset_of
Object.infect_an_assertion :assert_records_are_like, :must_have_records_like

module Enumerable
  def distances_between elem
    d = 0
    cnt = 0
    ds = []
    each do |e|
      if e == elem
        cnt += 1
        ds << d
        d = 0
      else
        d += 1
      end
    end
    ds << d
    ds
  end
end

class Object
  def mock_stub name, retval, args=[], &block
    mock = MiniTest::Mock.new
    mock.expect name, retval, args
    stub name, proc{|*args| mock.method_missing(name,*args)} do
      yield
    end
    mock.verify
  end
end

require 'spec_helper'
require 'spread'

describe Spread do

  {
    'large difference in length' => [ 9.times.map{1}, 3.times.map{2} ],
    'small difference in length' => [ 9.times.map{1}, 8.times.map{2} ],
    'same length' => [ 9.times.map{1}, 9.times.map{2} ],
    'more than two collections' => [ 5.times.map{1}, 9.times.map{2}, 13.times.map{3} ],
    'degenerates upfront' => (10.times.map{|i| [i]} + [ 3.times.map{100} ]),
    'degenerates behind' => ([ 3.times.map{100} ] + 10.times.map{|i| [i]}),
    'degenerates around' => (10.times.map{|i| [i]} + [ 3.times.map{100} ] + 10.times.map{|i| [i]}),
  }.each do |title, data|
    describe title do
      before do
        @collections = data
        @mix = Spread.spread *@collections
      end
      it 'uses all elements' do
        @mix.count.must_equal @collections.reduce(0){|sum,enum|sum+enum.count}
      end
      it 'keeps elements of the same collection apart' do
        @collections.each do |collection|
          @mix.distances_between(collection[0]).max.must_be :<=, @mix.count / collection.count
        end
      end
    end
  end
end


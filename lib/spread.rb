module Spread
  def self.spread_two a, b
    a,b = b,a if a.count < b.count
    avg_d = a.count.to_f / (b.count+1)
    offs = 0

    result = []
    b.each do |b_elem|
      from = offs.floor
      offs += avg_d
      to = offs.floor
      result << a[from...to]
      result << b_elem
    end

    result << a[offs.to_i..-1]
    result.flatten
  end

  def self.spread *args
    return [] if args.empty?
    return args[0] if args.count == 0

    args = args.sort_by{|array|array.count}

    mix = args.shift
    while enum = args.shift
      mix = spread_two mix, enum
    end
    mix
  end
end

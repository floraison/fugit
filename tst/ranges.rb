
#
# exploring ranges...

# 0-59
# 10~30

class R
  include Comparable

  MAX = 59
  attr_reader :current, :type, :slash

  def initialize(current, type, slash)
    @current = current
    @type = type
    @slash = slash
  end

  def to_i
    @current
  end

  def <=>(b)
    current <=> b.to_i
  end
  def succ
    c = current
    loop do
      c = c.succ
      return R.new(c, type, slash) if (c % slash) == 0
      fail 'overflow' if c > MAX
    end
  end
end

p (R.new(0, :hyphen, 1)..R.new(59, :hyphen, 1)).to_a.size

range = R.new(0, :hyphen, 2)..R.new(59, :hyphen, 2)
p range.to_a.size

p range.include?(0)
p range.include?(1)
p range.include?(2)
p range.include?(100)

p range.cover?(R.new(10, :hyphen, 2)..R.new(20, :hyphen, 2))
p range.cover?(R.new(10, :hyphen, 2)..R.new(70, :hyphen, 2))
p range.cover?(R.new(10, :hyphen, 1)..R.new(20, :hyphen, 1))

p range.to_a.collect(&:to_i)


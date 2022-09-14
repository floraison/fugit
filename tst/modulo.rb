
def show(mod0, mod1)

  puts "%#{mod0}+#{mod1}"
  (mod0 + 1).times do |i|
    print "%3d:  " % [
      i ]
    print "%d %% %d --> %d" % [
      i, mod0, i % mod0 ]
    print "  |  %d %% %d == %d --> %5s" % [
      i, mod0, i % mod0, (i % mod0) == mod1 ]
    print "  |  (%d + %d) %% %d == 0 --> %5s" % [
      i, mod0, mod1, (i + mod1) % mod0 == 0 ]
    print "  |  %d %% %d == %d %% %d --> %5s" % [
      i, mod0, mod1, mod0, i % mod0 == mod1 % mod0 ]
    puts
  end
end

puts; show(2, 1)
puts; show(3, 2)
puts; show(2, 2)
puts; show(2, 4)
puts; show(4, 3)


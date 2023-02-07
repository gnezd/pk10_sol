#!/usr/bin/ruby
require 'gsl'
# FEM solving of
# a F''(x) + b F'(x) + c F(x) = d with x ∊ (x1, x2)

x0 = 0.0
x1 = 1.0
n = 3
a = 0
b = 1
c = 2
d = 1
dx = (x1-x0)/(n)
# Set up Matrices 
# <F''(x)|φ>
dd_arr = (0..n).map do |i|
  (0..n).map do |j|
    case i-j
    when 0
      (i==0 || i==n)? -1 : -2
    when 1, -1
      1
    else
      0
    end
  end
end
#puts dd_arr
dd = GSL::Matrix.alloc(dd_arr.flatten, n+1, n+1)
puts "dd"
puts dd

# <F'(x)|φ>
d1_arr = (0..n).map do |i|
  (0..n).map do |j|
   case i-j 
   when 0
    0
   when -1
    0.5
   when 1
    -0.5
   else
    0
   end
  end
end
d1 = GSL::Matrix.alloc(d1_arr.flatten, n+1, n+1)
puts "d1"
puts d1

# <F(x)|φ>`
f_arr = (0..n).map do |i|
  (0..n).map do |j|
   case i-j 
   when 0
    (i==0 || i ==n)? 1.0/3 : 2.0/3
   when 1, -1
    1.0/6
   else
    0
   end
  end
end
f = GSL::Matrix.alloc(f_arr.flatten, n+1, n+1)
puts "f"
puts f

# c vector
const_arr = (1..n).map {d*dx}
const_arr[-1] /= 2

big_operator = a*dd/dx + b*d1 + c*dx*f

const = GSL::Matrix.alloc(const_arr, 1, n-1) - big_operator.submatrix(nil, 0)

puts "const"
puts const
puts "operator"
puts big_operator

m = big_operator.submatrix(nil, 1..n)
answer = (m.transpose * m).inv * m.transpose * const
#answer = (big_operator.inv*const).to_a.flatten
fout = File.open 'answer.txt', 'w'
answer.each_index do |i|
  fout.puts "#{x0+i*dx+dx} #{answer[i]}"
end
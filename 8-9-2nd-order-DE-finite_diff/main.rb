#!/usr/bin/ruby
# Solve: T(x)'' + 0.01(Ta-T) = 0
# T(0) = 40
# T(10) = 200

# Fuxx it! Solve the general form:
# F''(x) + a F'(x) + b F(x) = c with x ∊ (x1, x2)
# with boundary conditions F(x1) and F(x2) given
# solve by segmenting (A, B) into n segments

require 'gsl'

puts "How many slices?"
n = gets.to_i

match = nil
first_ask = true
while !match
  puts "\nBoundary condition format not recognized, try again." unless first_ask
  puts "Provide values at boundaries in format F(1) = 3; F(2) = 4"
  match = gets.match /^F\(([0-9\.E\-]+)\)\s?=\s?([0-9\.E\-]+);\s?F\(([0-9\.E\-]+)\)\s?=\s?([0-9\.E\-]+)/
  first_ask = false
end
bc = [ [match[1].to_f, match[2].to_f], [match[3].to_f, match[4].to_f] ].sort {|condition| condition[0]} # Boundary Conditions
puts bc.join ';'
raise "x1 cannot be the same as x2!!" if bc[0][0] == bc[1][0]

puts "Now input the coefficients (a, b, c) for this form:
F''(x) + a F'(x) + b F(x) = c
separated by comma:"
a, b, c = gets.split(',').map {|entry| entry.to_f}

puts "---- Solving -----"
puts "F''(x) + #{a} F'(x) + #{b} F(x) = #{c}, x ∊ #{bc[0][0]}, #{bc[1][0]})"
puts "with boundary conditions:"
puts "F(#{bc[0][0]}) = #{bc[0][1]}, F(#{bc[1][0]}) = #{bc[1][1]}"

puts "Constructing matrices"
#puts "D:"
d_arr = (0..n-2).map do |i|
  (0..n-2).map do |j|
    case (i-j)
    when 1
      -1
    when -1
      1
    else
      0
    end
  end
end
d = GSL::Matrix.alloc(d_arr.flatten, n-1, n-1)
#puts d

#puts "D^2:"
dd_arr = (0..n-2).map do |i|
  (0..n-2).map do |j|
    case (i-j)
    when 1, -1
      1
    when 0
      -2
    else
      0
    end
  end
end
dd = GSL::Matrix.alloc(dd_arr.flatten, n-1, n-1)
#puts dd

dx = (bc[1][0] - bc[0][0])/n
big_operator = dd/(dx**2) + a  / (2*dx) * d + b * GSL::Matrix.I(n-1)
#puts dx
#puts big_operator
const_arr = (0..n-2).map {c}
const_arr[0] += (a/(2*dx)-1/(dx**2))*bc[0][1]
const_arr[-1] += (-1.0)*(a/(2*dx)+1/(dx**2))*bc[1][1]
const = GSL::Matrix.alloc(const_arr.flatten, 1, n-1)
#puts const

answer = (const * big_operator.inv).to_a.flatten
#puts answer
fout = File.open 'answer.txt', 'w'

answer.each_index do |i|
  fout.puts "#{bc[0][1] + i*dx} #{answer[i]}"
end
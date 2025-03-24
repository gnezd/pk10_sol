require 'pry'

fin = File.open '../../pk10/2-3-solving_equations/J_1_0-20.txt', 'r'
data = fin.read.split("\n").map{|pt| pt.split(' ').map{|value| value.to_f}}

# Expand Bessel function of the 1st kind with Froebinius series
# Notation reference: https://en.wikipedia.org/wiki/Bessel_function
# {\displaystyle J_{\alpha }(x)=\sum _{m=0}^{\infty }{\frac {(-1)^{m}}{m!\Gamma (m+\alpha +1)}}{\left({\frac {x}{2}}\right)}^{2m+\alpha },}
def j(x, a, exp_order)
  result = 0.0
  (0..exp_order).each do |m|
    result +=
    ((-1)**m).to_f / (Math.gamma(m+1) * Math.gamma(m+1+a)) * ((x.to_f / 2)**(m.to_f*2+a))
  end
  result
end

# Interpolate to a series of points (x, f(x)) in R2
def interpol(x, data)
  #data_sorted = data.sort_by {|x| x[0]}
  data_sorted = data
  (0..data_sorted.size-2).each do |i|
    raise "Not a function! Double definition at #{data_sorted[i][0]}" if data_sorted[i][0] == data_sorted[i+1][0]
    if x >= data_sorted[i][0] && data_sorted[i+1][0] >= x
      return ((x-data_sorted[i][0])*data_sorted[i+1][1]+(data_sorted[i+1][0]-x)*data_sorted[i][1])/(data_sorted[i+1][0]-data_sorted[i][0])
    end
  end
  return nil
  
end

def deriv(f, x, step)
  raise "f is not proc" unless f.is_a?(Proc)
  (f.yield(x+step)-f.yield(x))/step
end


def euler(func, init, tolerance)
  n = 1
  diff_step = 1E-4
  # Compute derivative
  d = deriv(func, init, diff_step)
  # Now with approx form y = d*(x-x_0) + y_0 the new x will be -y_0/d + x_0
  next_pt = -func.yield(init)/d + init
  puts "Now gets to: #{next_pt} with slope #{d}"
  while ((func.yield(next_pt))**2 > tolerance**2)
    n += 1
    d = deriv(func, next_pt, diff_step)
    next_pt = -func.yield(next_pt)/d + next_pt
    puts "Now gets to: #{next_pt} with slope #{d} on #{n}th iteration"
  end
  puts "Converges to: #{next_pt} with func(x) = #{func.yield(next_pt)}"
  next_pt
end

# Find f(x)=0 in (a,b)
def median_search(f, a, b, tolerance, probe_density=10)
  step = (b-a).to_f/probe_density
  return [(a+b).to_f / 2] if step < tolerance
  values = (0..probe_density).map {|i| f.yield(a+i*step)}
  flips = []
  (0..values.size-2).each do |i|
    flips.push i if values[i]*values[i+1] < 0
  end
  #puts "Flips:"
  #puts flips.map{|i| "#{i} #{a+i*step} #{values[i]}"}
  
  (flips.map {|i| median_search(f, a+i*step, a+(i+1)*step, tolerance)}).reduce :+
  
end


# Find f(x)=0 in (a,b) where f(a)*f(b) < 0
def weighted_search(f, a, b, tolerance)
  step = (b-a).to_f
  cut = (a*(f.yield(a).abs) + b*(f.yield(b).abs))/(f.yield(a).abs+f.yield(b).abs)
  puts "Stepsize: #{b} - #{a} = #{step}"
  puts "cutting to #{cut}"
  return (a+b).to_f / 2 if step**2 < tolerance**2
  if f.yield(cut) * f.yield(a) < 0
    return weighted_search(f, a, cut, tolerance)
  elsif f.yield(cut) * f.yield(b) < 0
    return weighted_search(f, cut, b, tolerance)
  else
    return cut
  end
end

def max(func, a, b, tolerance, probe_density=100)
  slice = (b-a).to_f / probe_density
  sampling = (0..probe_density).map {|i| a + i*slice}
  values = sampling.map {|x| func.yield(x)}
  maxes = []
  (1..probe_density-2).each do |i|
    maxes.push i if values[i+1] >= values[i] && values[i+1] >= values[i+2]
  end
  return maxes.map {|i| sampling[i]} if slice < tolerance
  (maxes.map{|i| max(func, sampling[i-1], sampling[i+1], tolerance, probe_density)}).reduce :+
end
#func = Proc.new {|x| interpol(x, data)}
#func = Proc.new {|x| Math.sin(x)}
func = Proc.new {|x| j(x, 1, 50)}
func = Proc.new {|x| Math.sin(1/x)}
func = Proc.new {|x| (3/x**3 - 1/x)*Math.sin(x) - Math.cos(x)*3/x**2}
#puts euler(func, 2.5, 1E-5)
x= median_search(func, 0.0, 20, 1E-5, 10)
#weighted_search(func, 8.5, 9.5, 1E-10)
puts "#{x} -> #{x.map {|xv| func.yield(xv)}}"
puts max(func, 9.5, 12, 1E-4)
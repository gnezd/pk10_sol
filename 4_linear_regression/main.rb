require 'gsl'
fin_a = File.open('../../pk10/4-linear_regression/a.txt', 'r').readlines
a_eq = fin_a.shift
data_a = fin_a.map{|line| line.split(' ').map{|v| v.to_f}}
fin_b = File.open('../../pk10/4-linear_regression/b.txt', 'r').readlines
b_eq = fin_b.shift
data_b = fin_b.map{|line| line.split(' ').map{|v| v.to_f}}

raise "??" unless data_a.all? {|pt| pt.size == 2}
puts "Equation for dataset a: #{a_eq.sub('#', '')}"

sampling = data_a.map{|pt| pt[0]}
x = GSL::Matrix.alloc((sampling.map{|x| [x, 1]}).reduce(:+), sampling.size, 2)
# Now we have X * coeff = y. coeff = (XtX)-1 Xt y
y = GSL::Matrix.alloc(data_a.map{|pt| pt[1]}).transpose
coeff = (x.transpose*x).invert * x.transpose * y
puts "Coeff. obtained from regression: #{coeff.transpose}"
  
puts "Equation for dataset b: #{b_eq.sub('#', '')}"

sampling = data_b.map{|pt| pt[0]}
x = GSL::Matrix.alloc((sampling.map{|x| [x**3, x**2, x, 1]}).reduce(:+), sampling.size, 4)
# Now we have X * coeff = y. coeff = (XtX)-1 Xt y
y = GSL::Matrix.alloc(data_b.map{|pt| pt[1]}).transpose
coeff = (x.transpose*x).invert * x.transpose * y
puts "Coeff. obtained from regression: #{coeff.transpose}"

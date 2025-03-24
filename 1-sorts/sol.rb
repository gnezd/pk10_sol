#!/usr/bin/ruby
# Solution to pokky's HW on sorting with benchmarking
require 'pry'
require 'benchmark'

def native_sort(unsorted)
  unsorted.map{|question| question.dup.sort}
end

def bubble(unsorted)
  result = []
  unsorted.dup.each do |question|
    i = 0
    flips = 1
    while flips > 0
      i = 0
      flips = 0
      while i < question.size-1
        if question[i] <= question[i+1]
        else
          question[i], question[i+1] = question[i+1], question[i]
          flips += 1
        end
        i += 1
      end
    end
    result.push question
  end
end

def merge_sorts(unsorted)
  result = []
  unsorted.dup.each do |question|
    result.push merge_sort(question)
  end
  result
end

def merge_sort(unsorted)
  return unsorted if unsorted.size == 1
  if unsorted.size == 2
    if unsorted[1] >= unsorted[0]
      return unsorted[0..1] 
    else
      return [unsorted[1], unsorted[0]]
    end
  else
    result = []
    a = merge_sort(unsorted[0..unsorted.size/2])
    b = merge_sort(unsorted[unsorted.size/2+1..-1])
    while a.size > 0 && b.size >0
      if a[0] < b[0]
        result.push a.shift
      else
        result.push b.shift
      end
    end
    result += a
    result += b
    return result
  end
end

def qsort(unsorted)
  pivot = unsorted.size-1
  comp = unsorted.size-2
  #puts "unsorted: #{unsorted.join(' ')}"
  while comp >= 0 && pivot > 0
    #puts "picking pivot at #{pivot}: #{unsorted[pivot]}"
    #puts "comp: #{comp}: #{unsorted[comp]}"
    if unsorted[comp] <= unsorted[pivot]
      comp -= 1
    else
      unsorted[comp], unsorted[pivot], unsorted[pivot-1] = unsorted[pivot-1], unsorted[comp], unsorted[pivot]
      pivot -= 1
      comp -= 1
    end
    #puts "after reorienting: #{unsorted.join(' ')}"
  end
  result = []
  result += qsort(unsorted[0..pivot-1]) if pivot > 0
  result += [unsorted[pivot]]
  result += qsort(unsorted[pivot+1..-1]) if pivot < unsorted.size-1
  #puts "return: #{result}"
  result
end

def qsorts(unsorted)
  unsorted.dup.map {|q| qsort(q)}
end


puts "Starting everything at #{Time.now}"
input = File.open('../../pk10/1-sorts/testdata.txt', 'r').readlines.map {|line| line.split(' ').map {|entry| entry.to_i}}
answer = File.open('../../pk10/1-sorts/solution.txt', 'r').readlines.map {|line| line.split(' ').map {|entry| entry.to_i}}

# Not caring about corectness at the moment
native_ans = []
bubble_ans = []
merge_ans = []
qsort_ans = []
Benchmark.benchmark do |bx|
#  bx.report("native") {native_ans = native_sort(input)}
#  bx.report("bubble") {bubble_ans = bubble(input)}
#  bx.report("merge") {merge_ans = merge_sorts(input)}
#  bx.report("qsort") {qsort_ans = qsorts(input)}
end

begin
merge_ans.each_with_index do |run, r|
  run.each_index do |i|
    raise unless run[i] == answer[r][i]
  end
end
rescue
  puts "run #{r} mismatch: #{i}-th should be #{answer[r][i]} and not #{run[i]}}"
  binding.pry
end

puts "Everything finished at #{Time.now}"
#!/usr/bin/ruby
# Solution to pokky's HW on sorting with benchmarking
require 'pry'
require 'benchmark'

def native_sort(unsorted)
  unsorted.map{|question| question.sort}
end

def bubble(unsorted)
  result = []
  unsorted.each do |question|
    i = 0
    streak = 0
    # `streak` for recording the number of correct orientation
    while i < question.size-1 && streak < question.size-1
      if question[i] <= question[i+1]
        streak += 1
      else
        question[i], question[i+1] = question[i+1], question[i]
      end
      i += 1
    end
    result.push question
  end
end

def merge_sorts(unsorted)
  result = []
  unsorted.each do |question|
    result.push merge(question, 2)
  end
  result
end

def merge(unsorted, split = 2)
  result = []
  if unsorted.size == 1
    return unsorted
  elsif unsorted.size ==2
    return (unsorted[1] >= unsorted[0]) ? unsorted : unsorted.reverse
  else
    chunksize = unsorted.size/split
    splitted = (0..split-1).map {|i| unsorted[i*chunksize..(i+1)*chunksize-1]}
    splitted[-1] += unsorted[(split*chunksize)..-1]
    sorted_parts = splitted.map{|unsorted| merge(unsorted)}
    while (sorted_parts.map{|part| part.size}).all? {|len| len > 0}
      # Only split 2 for now
      if sorted_parts[0][0] <= sorted_parts[1][0]
        result.push sorted_parts[0].shift
      else
        result.push sorted_parts[1].shift
      end
    end
    result
    if result.size != unsorted.size
      puts "#{unsorted} -> #{sorted_parts.join('|')} -> #{result}"
      binding.pry
    end
  end
end

puts "Starting everything at #{Time.now}"
input = File.open('../../pk10/1-sorts/testdata.txt', 'r').readlines.map {|line| line.split(' ').map {|entry| entry.to_i}}
answer = File.open('../../pk10/1-sorts/solution.txt', 'r').readlines.map {|line| line.split(' ').map {|entry| entry.to_i}}

# Not caring about corectness at the moment
native = []
bubble = []
merge = []
Benchmark.bmbm do |benchmark|
  benchmark.report("native") {native = native_sort(input)}
  benchmark.report("bubble") {bubble = bubble(input)}
  benchmark.report("merge") {merge = merge_sorts(input)}
end
puts merge

puts "Everything finished at #{Time.now}"
#!/usr/bin/env ruby

begin
  require "rubygems"
  gem "my_first_markov"
  require "my_first_markov"
rescue LoadError => e
  warn "LoadError: #{e.message.inspect}"
  require_relative "../lib/my_first_markov"
end

if File.basename(__FILE__) == File.basename($PROGRAM_NAME)
  starting_entry = ARGV[0]
  file = ARGV[1]
  next_method = ARGV[2]
  split_on = ARGV[3]

  if [starting_entry, file].include?(nil) || (starting_entry =~ /(\-\-\?)|(\-\-help)/i)
    msg = <<-EOH
      $0 <some starting entry> <file-glob of entry observations> <split_on: word* | character> <next_method: random_next* | most_likely_next>
      e.g.
      $0  this                  ./test/sample_text.txt        [random_next]         [word]
      > apple

      $0  a                    ./test/sample_text.txt         [random_next]         character
      > p

      OR

      $0 <firstN> <file-glob of entry observations> <split_on: word* | character> <next_method: first>
    EOH
    warn(msg)
    exit
  elsif starting_entry =~ /\-\-first/
    next_method = starting_entry.dup[2..-1]
    starting_entry = nil
    #puts "calling MyFirstMarkov::Chain.file_to_entries(#{file}, #{split_on.inspect}, #{starting_entry.inspect}, #{next_method.inspect})"
    entries, _na, next_method, count = MyFirstMarkov::Chain.file_to_entries(file, split_on, starting_entry, next_method)
    mc = MyFirstMarkov::Chain.new(entries)
    puts mc.send(next_method, count)
    exit
  end

  #puts "calling MyFirstMarkov::Chain.from_file(#{file}, #{split_on.inspect}, #{starting_entry.inspect}, #{next_method.inspect})"
  puts MyFirstMarkov::Chain.from_file(file, split_on, starting_entry, next_method)
end

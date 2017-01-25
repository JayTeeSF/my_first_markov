#!/usr/bin/env ruby

begin
  require "rubygems"
  gem "markov"
  require "markov"
rescue LoadError => e
  warn "LoadError: #{e.message.inspect}"
  require_relative "../lib/markov"
end

if File.basename(__FILE__) == File.basename($PROGRAM_NAME)
  starting_entry = ARGV[0]
  puts "ARGV[0]: #{ARVG[0].inspect}, ARGV[1]: #{ARGV[1].inspect}, ARGV[2]: #{ARGV[2].inspect}"
  if starting_entry =~ /(\-\-\?)|(\-\-help)/i || ARGV[1].nil?
    msg = <<-EOH
      $0 <some starting entry> <split-on: word|character> <file-glob of entry observations>
      e.g.
      $0  It                  word                       ./emails/*.eml
      > was

      $0  A                    character                  ./some_writing_sample.txt
      > Apple
    EOH
    warn(msg)
    exit
  end

  entries = File.read(ARGV[1])
  Markov::Chain.new(starting_entry, entries)
end

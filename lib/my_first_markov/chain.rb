# ./bin/my_first_markov.rb --first ./test/sample_text.txt
# ./bin/my_first_markov.rb apple ./test/sample_text.txt
# ./bin/my_first_markov.rb apple ./test/sample_text.txt most_likely_next
require 'json'
module MyFirstMarkov
  class Chain
    DEFAULT_COUNT = 5
    DEFAULT_DEBUG = true

    def self.next_methods
      ["random_next", "most_likely_next", "first"]
    end

    def self.default_next_method
      next_methods.first
    end

    def self.split_on_values
      ["word", "character"]
    end

    def self.default_split_on_value
      split_on_values.first
    end

    def self.from_downcase_file(file, split_on, starting_entry, next_method)
      entries, starting_entry, next_method, count = file_to_entries(file, split_on, starting_entry, next_method)
      return from_entries(entries.map(&:downcase), starting_entry, next_method, count)
    end

    def self.from_file(file, split_on, starting_entry, next_method)
      from_entries(*file_to_entries(file, split_on, starting_entry, next_method))
    end

    def self.file_to_entries(file, split_on, starting_entry, next_method)
      unless split_on && MyFirstMarkov::Chain.split_on_values.include?(split_on.downcase)
        split_on = MyFirstMarkov::Chain.default_split_on_value
      end

      if next_method
        if matches = next_method.match(/^(\D+)(\d+)$/)
          next_method = matches[1]
          count = matches[2]
          unless MyFirstMarkov::Chain.next_methods.include?(next_method.downcase)
            next_method = MyFirstMarkov::Chain.default_next_method
          end
        end
      else
        next_method = MyFirstMarkov::Chain.default_next_method
      end

      unless File.exists?(file)
        fail("Unknown file: #{file.inspect}")
      end

      data = File.read(file)
      ("word" == split_on.downcase) ? entries = data.split : entries = data.split(//)
      entries ||= []

      #puts "return [#{entries.inspect}, #{starting_entry.inspect}, #{next_method.inspect}, #{count || DEFAULT_COUNT}]"
      return [entries, starting_entry, next_method, count || DEFAULT_COUNT]
    end

    def self.from_entries(entries, starting_entry, next_method, count)
      new(entries).send(next_method.downcase, starting_entry, count)
    end

    def initialize(ordered_entries, debug=DEFAULT_DEBUG)
      @debug = debug
      @entries = Hash.new
      ordered_entries.each_with_index do |entry, index|
        next_entry_idx = next_idx_or_nil(index, ordered_entries.size)
        add(entry, ordered_entries[next_entry_idx]) if next_entry_idx
      end
    end

    def add(entry, next_entry)
      @entries[entry] ||= Hash.new(0)
      @entries[entry][next_entry] += 1
    end

    def first(count=nil)
      count ||= DEFAULT_COUNT
      # @entries.keys.sort {|a,b| num_observations_for(b) <=> num_observations_for(a) }.take(count)
      results = @entries.keys.reduce({}) { |memo, key|
        memo[key] = num_observations_for(key); memo
      }.sort { |a,b| num_observations_for(b.first) <=> num_observations_for(a.first) }
        .take(count.to_i)

      if (@debug)
        results.reduce({}) { |memo, ary| memo[ary.first] = ary.last; memo }.to_json
      else
        #results.first
        results.map(&:first).to_json # the "entry" part, not the "num_observations"
      end
    end

    def most_likely_next(entry, count=nil)
      count ||= DEFAULT_COUNT
      _next(entry) do |observation_total, next_entries_and_observations|
        results = next_entries_and_observations
          .sort {|a,b| b.last <=> a.last} # sort (in reverse) by observations
          .take(count.to_i) # choose the array(s) with the largest observation (could be many with same #)

        if (@debug)
          # debug:
          results.reduce({}) { |memo, ary| memo[ary.first] = ary.last; memo }.to_json
        else
          results.map(&:first).to_json # the "entry" part, not the "num_observations"
        end
      end
    end

    def random_next(entry, count=nil)
      count ||= 1
      #puts "called w/ entry: #{entry.inspect}, count: #{count.inspect}"
      _next(entry) do |observation_total, next_entries_and_observations|
        random_threshold = rand(observation_total) + 1
        partial_observation_sum = 0

        results = next_entries_and_observations.select { |next_entry, num_observations|
          partial_observation_sum += num_observations
          partial_observation_sum >= random_threshold
        }.take(count.to_i)

        if (@debug)
          # debug:
          #{ result.first => result.last }.to_json
          results.reduce({}) { |memo, ary| memo[ary.first] = ary.last; memo }.to_json
        else
          #result.first # the "entry" part, not the "num_observations"
          results.map(&:first).to_json # the "entry" part, not the "num_observations"
        end
      end
    end


    private

    def num_observations_for(entry)
      @entries[entry].reduce(0) {|sum,entry_observations| sum += entry_observations.last}
    end

    def _next(entry, &block)
      return "" unless @entries.key?(entry)

      # remember each entry contains a hash of the form {subsequent_entry: num_of_observations, other_subsequent_entry: num_of_observaions, ...}
      # calling reduce on a hash converts to an array [[s_entry, observation_count], ...]
      num_of_observations = num_observations_for(entry)
      return block.call(num_of_observations, @entries[entry])
    end

    def next_idx_or_nil(idx, list_size)
      last_idx_in_list = list_size - 1
      (idx + 1 < last_idx_in_list) ? idx + 1 : nil
    end
  end
end

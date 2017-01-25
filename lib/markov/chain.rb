module Markov
  class Chain
    def initialize(ordered_list)
      @entries = Hash.new
      ordered_list.each_with_index do |entry, index|
        next_entry_idx = next_idx_or_nil(index, ordered_list.size)
        add(entry, ordered_list[next_entry_idx]) if next_entry_idx
      end
    end

    def add(entry, next_entry)
      @entries[entry] ||= Hash.new(0)
      @entries[entry][next_entry] += 1
    end

    def most_likely_next(entry)
      _next(entry) do |observation_total, next_entries_and_observations|
        next_entries_and_observations
          .sort {|a,b| b.last <=> a.last} # sort (in reverse) by observations
          .first # choose an array with the largest observation (could be many with same #)
          .first # the "entry" part, not the "num_observations"
      end
    end

    def random_next(entry)
      _next(entry) do |observation_total, next_entries_and_observations|
        random_threshold = rand(observation_total) + 1
        partial_observation_sum = 0

        next_entries_and_observations.find { |next_entry, num_observations|
          partial_observation_sum += num_observations
          partial_observation_sum >= random_threshold
        }.first # we want the "entry" not the "num_observations"
      end
    end


    private

    def _next(entry, &block)
      return "" unless @entries.key?(entry)

      # remember each entry contains a hash of the form {subsequent_entry: num_of_observations, other_subsequent_entry: num_of_observaions, ...}
      # calling reduce on a hash converts to an array [[s_entry, observation_count], ...]
      num_of_observations = @entries[entry].reduce(0) {|sum,entry_observations| sum += entry_observations.last}
      return block.call(num_of_observations, @entries[entry])
    end

    def next_idx_or_nil(idx, list_size)
      last_idx_in_list = list_size - 1
      (idx + 1 < last_idx_in_list) ? idx + 1 : nil
    end
  end
end
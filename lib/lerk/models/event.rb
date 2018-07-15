module Lerk
  class Event < Sequel::Model
    one_to_many :event_counters

    def self.get_or_create(key, stats_output_order:)
      first(key: key) || Event.create(key: key, stats_output_order: stats_output_order)
    end

    def self.register(key:, show_in_stats_output: false, stats_output_description: '', stats_output_order: 0)
      event = get_or_create(key, stats_output_order: stats_output_order)
      event.update(
        show_in_stats_output: show_in_stats_output,
        stats_output_description: stats_output_description,
        stats_output_order: stats_output_order,
      )

      event
    end

    def count(user, count: 1)
      counter = EventCounter.get_or_create(self, user)
      counter.update(count: counter.count + count)
    end
  end
end

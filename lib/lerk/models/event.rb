module Lerk
  class Event < Sequel::Model
    one_to_many :event_counters

    def self.get_or_create(key)
      first(key: key) || Event.create(key: key)
    end

    def count(user, count: 1)
      counter = EventCounter.get_or_create(self, user)
      counter.update(count: counter.count + count)
    end
  end
end

module Lerk
  class EventCounter < Sequel::Model
    many_to_one :event
    many_to_one :discord_user

    def self.get_or_create(event, user)
      first(event: event, discord_user: user) || EventCounter.create(event: event, discord_user: user)
    end
  end
end

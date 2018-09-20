module Lerk
  class DiscordUser < Sequel::Model
    one_to_many :event_counters

    def self.get_or_create(discord_id, last_nick: nil)
      user = first(discord_id: discord_id)
      if user
        user.update(last_nick: last_nick) if last_nick

        user
      else
        DiscordUser.create(discord_id: discord_id, last_nick: last_nick || 'UNKNOWN_NICK')
      end
    end

    def ignore
      update(ignored: true)
    end

    def unignore
      update(ignored: false)
    end
  end
end

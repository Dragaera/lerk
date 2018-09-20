module Lerk
  module Util
    def self.discord_user_from_database(event)
      # Nickname is the optional per-server name a user can choose freely.
      # However, it will be undefined for eg DMs.
      nickname = event.user.nickname || event.user.username
      DiscordUser.get_or_create(event.user.id.to_s, last_nick: nickname)
    end

    def self.ignored?(event)
      user = discord_user_from_database(event)
      user.ignored
    end
  end
end

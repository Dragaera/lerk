module Lerk
  module Util
    def self.discord_user_from_database(event)
      # Nickname is the optional per-server name a user can choose freely.
      # However, it will be undefined for eg DMs.
      nickname = event.user.nickname || event.user.username
      DiscordUser.get_or_create(event.user.id.to_s, nickname)
    end
  end
end

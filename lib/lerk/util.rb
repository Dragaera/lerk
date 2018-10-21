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

    def self.resolve_steam_account_id(s)
      begin
        SteamID.from_string(s, api_key: Config::HiveInterface::STEAM_WEB_API_KEY).account_id
      rescue WebApiError, ArgumentError => e
        puts "Error: Could not convert #{ s } to account ID: #{ e.message }"
        nil
      end
    end

  end
end

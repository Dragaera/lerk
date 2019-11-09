require 'securerandom'

module Lerk
  class DiscordUser < Sequel::Model
    one_to_many :event_counters

    OAUTH_SCOPES = %w(connections)
    DISCORD_CONNECTIONS_ENDPOINT = '/api/users/@me/connections'

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

    def oauth_auth_url
      regenerate_oauth_secret

      client = Config::DiscordOAuth.client
      client.auth_code.authorize_url(
        redirect_uri: Config::DiscordOAuth::CALLBACK_URL,
        scope: OAUTH_SCOPES.join(','),
        state: oauth_secret
      )
    end

    def link_discord_connections(code:)
      token = exchange_oauth_code(code)
      api_response = token.get(
        DISCORD_CONNECTIONS_ENDPOINT
      )

      connections = JSON.parse(api_response.body)
      steam = connections.select { |con| con['type'] == 'steam' }.first
      return nil unless steam

      steam_id = Util.resolve_steam_account_id(steam.fetch('id'))
      verified = steam.fetch('verified')

      if steam_id
        update(
          steam_account_id: steam_id,
          steam_account_verified: verified
        )

        # Bit of an overkill, but this way it'll just work if we link other
        # accounts in the future
        return [
          {
            type: 'steam',
            id: steam_id
          }
        ]
      else
        return nil
      end
    end

    def exchange_oauth_code(access_code)
      client = Config::DiscordOAuth.client

      token = client.auth_code.get_token(
        access_code,
        redirect_uri: Config::DiscordOAuth::CALLBACK_URL,
        scope: OAUTH_SCOPES.join(',')
      )

      # Store refresh token for later usage
      # Also purge the secret, as access codes are valid for one request only.
      # This'll prevent (accidental) attempts at reusing access codes.
      update(
        refresh_token: token.refresh_token,
        oauth_secret:   nil
      )

      return token
    end

    private
    def regenerate_oauth_secret
      # Theoretically subject to a race condition, which would be caught by the
      # DB's unique constraint (and lead to an exception). Extremely unlikely
      # however, given the expected traffic.
      secret = SecureRandom.hex(16)
      while DiscordUser.where(oauth_secret: secret).count > 0
        secret = SecureRadom.hex(16)
      end
      update(oauth_secret: secret)
    end
  end
end

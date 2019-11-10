require 'securerandom'

module Lerk
  class DiscordUser < Sequel::Model
    one_to_many :event_counters

    OAUTH_SCOPES = %w(connections identify)

    @@logger = ::Lerk.logger

    def self.get_or_create(discord_id, last_nick: nil)
      user = first(discord_id: discord_id)
      if user
        user.update(last_nick: last_nick) if last_nick

        user
      else
        DiscordUser.create(discord_id: discord_id, last_nick: last_nick || 'UNKNOWN_NICK')
      end
    end

    def logger
      @@logger
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
        scope: OAUTH_SCOPES.join(' '),
        state: oauth_secret
      )
    end

    def link_discord_connections(code:)
      logger.debug("OAuth: Exchanging code #{ code } for token")
      token = exchange_oauth_code(code)
      logger.debug("OAuth: Got token #{ token.token }")

      # discordrb passes the `token` parameter directly as contents of the
      # authorization header.
      auth = "Bearer #{ token.token }"

      api_discord_id = JSON.parse(
        Discordrb::API::User.profile(auth)
      ).fetch('id')
      logger.debug("User ID from Discord: #{ api_discord_id }, user ID from nonce: #{ discord_id }")
      unless api_discord_id == discord_id
        # The nonce (`state` parameter of OAuth call) gives us the Discord ID
        # of the person who used `!link`. A API call using the OAuth token
        # gives us the Discord ID of the person who clicked on the link (&
        # authorized access to their connections).
        # Only if both match do we actually link them in our DB. This prevents
        # linking your Steam account to others' Discord accounts, as well as
        # having others' Steam account linked to your Discord account.
        logger.warn("Mismatch between Discord IDs, potentially forged request. Aborting.")
        return nil
      end

      connections = JSON.parse(
        Discordrb::API::User.connections(auth)
      )

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
    rescue JSON::ParserError, RestClient::Exception, Errno::ECONNREFUSED, Discordrb::Errors::NoPermission => e
      logger.error("#{ e.class } while linking Discord connections: #{ e.message }")
      return nil
    end

    def exchange_oauth_code(access_code)
      client = Config::DiscordOAuth.client

      token = client.auth_code.get_token(
        access_code,
        redirect_uri: Config::DiscordOAuth::CALLBACK_URL,
        scope: OAUTH_SCOPES.join(' ')
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

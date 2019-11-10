Sequel.migration do
  up do
    alter_table :discord_users do
      add_column :oauth_secret,           String, null: true, unique: true
      add_column :refresh_token,          String, null: true
      add_column :steam_account_verified, TrueClass, null: false, default: false
    end
  end

  down do
    alter_table :discord_users do
      drop_column :oauth_secret
      drop_column :refresh_token
      drop_column :steam_account_verified
    end
  end
end

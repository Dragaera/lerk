module Lerk
  FactoryBot.define do
    to_create(&:save)

    factory :discord_user, class: 'Lerk::DiscordUser' do
      sequence(:discord_id)
      last_nick 'John'
    end

    factory :event, class: 'Lerk::Event' do
      sequence(:key)
    end

    factory :event_counter, class: 'Lerk::EventCounter' do
      event
      discord_user
      count 0
    end
  end
end

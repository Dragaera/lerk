module Lerk
  FactoryBot.define do
    to_create(&:save)

    factory :discord_user, class: 'Lerk::DiscordUser' do
      sequence(:discord_id)
      last_nick 'John'
    end

    factory :event, class: 'Lerk::Event' do
      sequence(:key)
      stats_output_description ''
      sequence(:stats_output_order)
      show_in_stats_output false
    end

    factory :event_counter, class: 'Lerk::EventCounter' do
      event
      discord_user
      count 0
    end
  end
end

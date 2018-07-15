module Lerk
  RSpec.describe DiscordUser do
    describe '::get_or_create' do
      let!(:user) { create(:discord_user, discord_id: '1', last_nick: 'John') }

      it "creates the user if he doesn't exist yet" do
        expect { DiscordUser.get_or_create('2', 'George') }.to change { DiscordUser.count }.by(1)

        new_user = DiscordUser.get_or_create('3', 'William')
        expect(new_user.discord_id).to eq '3'
        expect(new_user.last_nick).to eq 'William'
      end

      it 'retrieves the user if he exists already' do
        expect(DiscordUser.get_or_create('1', 'John')).to eq user
      end

      it "updated the user's username if he exists already" do
        expect(DiscordUser.get_or_create('1', 'John2').last_nick).to eq 'John2'
      end
    end
  end
end

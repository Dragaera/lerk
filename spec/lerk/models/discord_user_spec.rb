module Lerk
  RSpec.describe DiscordUser do
    describe '::get_or_create' do
      let!(:user) { create(:discord_user, discord_id: '1', last_nick: 'John') }

      it "creates the user if he doesn't exist yet" do
        expect { DiscordUser.get_or_create('2', last_nick: 'George') }.to change { DiscordUser.count }.by(1)

        new_user = DiscordUser.get_or_create('3', last_nick: 'William')
        expect(new_user.discord_id).to eq '3'
        expect(new_user.last_nick).to eq 'William'
      end

      it 'retrieves the user if he exists already' do
        expect(DiscordUser.get_or_create('1', last_nick: 'John')).to eq user
      end

      it "updated the user's username if he exists already" do
        expect(DiscordUser.get_or_create('1', last_nick: 'John2').last_nick).to eq 'John2'
      end

      it "does not update the user's nickname if none is supplied" do
        expect { DiscordUser.get_or_create('1') }.to_not change { DiscordUser.first(discord_id: '1').last_nick }
      end

      it "allows creating users without knowing their nick" do
        expect { DiscordUser.get_or_create('123') }.to_not raise_error
      end
    end
  end
end

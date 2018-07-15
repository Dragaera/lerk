module Lerk
  RSpec.describe EventCounter do
    describe '::get_or_create' do
      let(:event)    { create(:event) }
      let(:user)     { create(:discord_user) }
      let!(:counter) { create(:event_counter, event: event, discord_user: user) }

      it "creates the event counter if it doesn't exist yet" do
        new_user = create(:discord_user)

        expect { EventCounter.get_or_create(event, new_user) }.to change { EventCounter.count }.by(1)

        new_counter = EventCounter.get_or_create(event, new_user)
        expect(new_counter.event).to eq event
        expect(new_counter.discord_user).to eq new_user
        expect(new_counter.count).to eq 0
      end

      it 'retrieves the event counter if it exists already' do
        expect(EventCounter.get_or_create(event, user)).to eq counter
      end
    end
  end
end

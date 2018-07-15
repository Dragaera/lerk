module Lerk
  RSpec.describe Event do
    let!(:event) { create(:event, key: 'foo_bar') }
    let!(:user)  { create(:discord_user) }
    let!(:event_counter) { create(:event_counter, event: event, discord_user: user ) }

    describe '::register' do
      it 'creates the event with supplied arguments if needed' do
        event = Event.register(key: 'foo_baz', stats_output_description: 'Foo Baz', show_in_stats_output: false)
        expect(event.key).to eq 'foo_baz'
        expect(event.stats_output_description).to eq 'Foo Baz'
        expect(event.show_in_stats_output).to be false
      end

      it 'adjusts additional attributes if any changed' do
        create(:event, key: 'foo_baz', show_in_stats_output: true)
        expect(Event.register(key: 'foo_baz', show_in_stats_output: false).show_in_stats_output).to be false
      end

      it 'returns the event in any case' do
        expect(Event.register(
          key: event.key,
          show_in_stats_output: event.show_in_stats_output,
          stats_output_description: event.stats_output_description
        )).to eq event
      end
    end

    describe '::get_or_create' do
      it "creates the event if it doesn't exist yet" do
        expect { Event.get_or_create('foo_baz') }.to change { Event.count }.by(1)

        new_event = Event.get_or_create('bar_baz')
        expect(new_event.key).to eq 'bar_baz'
      end

      it 'retrieves the event if it exists already' do
        expect(Event.get_or_create('foo_bar')).to eq event
      end
    end

    describe '#count' do
      # 'Expect change' syntax won't work because object values are cached, so we have to do a manual `#refresh`.

      it 'increases the event counter for the given event/user combination' do
        expect(event_counter.count).to eq(0)
        event.count(user)
        event_counter.refresh
        expect(event_counter.count).to eq(1)
      end

      it 'supports increasing the count by arbitrary amounts' do
        expect(event_counter.count).to eq(0)

        event.count(user, count: 3)
        event_counter.refresh
        expect(event_counter.count).to eq(3)

        event.count(user, count: 2)
        event_counter.refresh
        expect(event_counter.count).to eq(5)
      end
    end
  end
end

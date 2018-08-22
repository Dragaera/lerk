module Lerk
  RSpec.describe HintTag do
    describe '::validate' do
      it 'ensures case-insensitive uniqueness of the tag' do
        create(:hint_tag, tag: 'test')
        expect { create(:hint_tag, tag: 'Test') }.to raise_error Sequel::ValidationFailed
      end
    end
  end
end

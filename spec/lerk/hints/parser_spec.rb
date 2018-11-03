module Lerk
  module Hints
    RSpec.describe Parser do
      let(:source) { Hints::LocalFileSource.new('spec/fixtures/hints.csv') }
      let(:parser) {Parser.new(source: source, variable_file: 'spec/fixtures/variables.json') }
      let(:hints) { parser.parse }

      describe '#parse' do
        it 'handles regular identifiers' do
          hint = hints[0]

          expect(hint[:text]).to eq 'Testing regular_identifier'
        end

        it 'handles short identifiers' do
          hint = hints[1]

          expect(hint[:text]).to eq 'Testing short'
        end

        it 'handles numeric identifiers' do
          hint = hints[2]

          expect(hint[:text]).to eq 'Testing numeric_1_identifier numeric_2'
        end

        it 'skips unknown identifiers' do
          hint = hints[3]

          expect(hint[:text]).to eq 'Testing UNKNOWN'
        end
      end
    end
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/contrast_pair_generator'

RSpec.describe OTLearn::ContrastPairGenerator do
  let(:grammar) { double('grammar') }
  let(:gramtester) { double('gramtester') }
  let(:contrastfinder) { double('contrastfinder') }
  let(:test_result) { double('test_result') }
  let(:o11) { double('output11') }
  let(:o12) { double('output12') }
  let(:o21) { double('output21') }
  let(:o22) { double('output22') }
  let(:r1s1) { double('r1s1') }
  let(:r1s2) { double('r1s2') }
  let(:r2s1) { double('r2s1') }
  let(:r2s2) { double('r2s2') }

  before do
    allow(grammar).to receive(:parse_output).with(o11).and_return(r1s1)
    allow(grammar).to receive(:parse_output).with(o12).and_return(r1s2)
    allow(grammar).to receive(:parse_output).with(o21).and_return(r2s1)
    allow(grammar).to receive(:parse_output).with(o22).and_return(r2s2)
  end

  context 'when r1s1 is a failed winner' do
    let(:outputs) { [o11, o12, o21, o22] }

    before do
      allow(gramtester).to receive(:run).with(outputs, grammar)\
                                        .and_return(test_result)
      allow(test_result).to receive(:failed_outputs).and_return([o11])
      allow(test_result).to receive(:success_outputs)\
        .and_return([o12, o21, o22])
    end

    context 'when r1s2 is a contrast word' do
      before do
        allow(contrastfinder).to receive(:contrast_words)\
          .with(r1s1, [r1s2, r2s1, r2s2], grammar).and_return([r1s2])
        @generator = described_class.new(outputs, grammar,
                                         contrast_finder: contrastfinder)
        @generator.grammar_tester = gramtester
      end

      it 'yields r1s1-r1s2' do
        expect { |probe| @generator.each(&probe) }.to \
          yield_with_args([r1s1, r1s2])
      end

      it 'produces an enumerator yielding r1s1-r1s2' do
        gen_enum = @generator.to_enum
        pairs = []
        loop { pairs << gen_enum.next }
        expect(pairs).to eq [[r1s1, r1s2]]
      end
    end

    context 'when [r1s2, r2s1] are contrast words' do
      before do
        allow(contrastfinder).to receive(:contrast_words)\
          .with(r1s1, [r1s2, r2s1, r2s2], grammar)\
          .and_return([r1s2, r2s1])
        @generator = described_class\
                     .new(outputs, grammar, contrast_finder: contrastfinder)
        @generator.grammar_tester = gramtester
      end

      it 'produces a enumerator yielding r1s1-r1s2 and r1s1-r2s1' do
        gen_enum = @generator.to_enum
        pairs = []
        loop { pairs << gen_enum.next }
        expect(pairs).to eq [[r1s1, r1s2], [r1s1, r2s1]]
      end
    end
  end

  context 'when r1s2 and r2s2 are failed winners' do
    let(:outputs) { [o11, o12, o21, o22] }

    before do
      allow(gramtester).to receive(:run).with(outputs, grammar) \
                                        .and_return(test_result)
      allow(test_result).to receive(:failed_outputs).and_return([o12, o22])
      allow(test_result).to receive(:success_outputs).and_return([o11, o21])
    end

    context 'when r1s2, r2s2 have contrast words [r2s2, r1s1], [r2s1]' do
      before do
        allow(contrastfinder).to receive(:contrast_words)\
          .with(r1s2, [r2s2, r1s1, r2s1], grammar)\
          .and_return([r2s2, r1s1])
        allow(contrastfinder).to receive(:contrast_words)\
          .with(r2s2, [r1s1, r2s1], grammar).and_return([r2s1])
        @generator = described_class\
                     .new(outputs, grammar, contrast_finder: contrastfinder)
        @generator.grammar_tester = gramtester
      end

      it 'produces an enumerator yielding r1s2-r2s2, r1s2-r1s1, r2s2-r2s1' do
        gen_enum = @generator.to_enum
        pairs = []
        loop { pairs << gen_enum.next }
        expect(pairs).to eq [[r1s2, r2s2], [r1s2, r1s1], [r2s2, r2s1]]
      end
    end
  end
end

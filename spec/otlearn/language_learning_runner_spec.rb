# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/language_learning_runner'

RSpec.describe 'OTLearn::LanguageLearningRunner' do
  let(:system){ double('system') }
  let(:learner){ double('learner') }
  let(:image_maker){ double('image_maker') }
  let(:label){ 'language_label' }
  let(:outputs){ double('outputs') }
  let(:result){ double('result') }
  before(:example) do
    allow(learner).to receive(:learn).and_return(result)
    allow(system).to receive(:constraints).and_return(['con1', 'con2'])
    @runner = OTLearn::LanguageLearningRunner.new(system, learner,
                                                  image_maker)
  end

  context 'when run is called' do
    before(:example) do
      @actual_result = @runner.run(label, outputs)
    end
    it 'runs the learner' do
      expect(learner).to have_received(:learn)
    end
    it 'returns a result' do
      expect(@actual_result).to eq result
    end
  end
end

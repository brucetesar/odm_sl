# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'odl/resolver'
require 'otlearn/language_learning_runner'

RSpec.describe OTLearn::LanguageLearningRunner do
  let(:system) { double('system') }
  let(:learner) { double('learner') }
  let(:image_maker) { double('image_maker') }
  let(:csvout_class) { double('csvout_class') }
  let(:label) { 'language_label' }
  let(:outputs) { double('outputs') }
  let(:result) { double('result') }

  before do
    allow(learner).to receive(:learn).and_return(result)
    allow(system).to receive(:constraints).and_return(%w[con1 con2])
    @runner = described_class.new(system, learner, image_maker: image_maker,
                                                   csvout_class: csvout_class)
  end

  context 'when run is called' do
    before do
      @actual_result = @runner.run(label, outputs)
    end

    it 'runs the learner' do
      expect(learner).to have_received(:learn)
    end

    it 'returns a result' do
      expect(@actual_result).to eq result
    end
  end

  context 'when write is called' do
    let(:result) { double('learning result') }
    let(:grammar) { double('grammar') }
    let(:sim_image) { double('sim_image') }
    let(:csvout) { double('csvout') }

    before do
      allow(result).to receive(:grammar).and_return(grammar)
      allow(grammar).to receive(:label).and_return(label)
      allow(image_maker).to receive(:get_image).and_return(sim_image)
      allow(csvout_class).to receive(:new).with(sim_image).and_return(csvout)
      allow(csvout).to receive(:write_to_file)
    end

    context 'with out_dir but not filename' do
      before do
        @rv = @runner.write(result, out_dir: 'mydir')
      end

      it 'creates an image of the simulation' do
        expect(image_maker).to have_received(:get_image).with(result)
      end

      it 'creates a csvoutput object with the simulation image' do
        expect(csvout_class).to have_received(:new).with(sim_image)
      end

      it 'writes the image to out_dir with the label-based filename' do
        expect(csvout).to have_received(:write_to_file)\
          .with('mydir/language_label.csv')
      end

      it 'returns nil' do
        expect(@rv).to be_nil
      end
    end

    context 'with filename but not out_dir' do
      before do
        @runner.write(result, filename: 'myfile')
      end

      it 'creates an image of the simulation' do
        expect(image_maker).to have_received(:get_image).with(result)
      end

      it 'creates a csvoutput object with the simulation image' do
        expect(csvout_class).to have_received(:new).with(sim_image)
      end

      it 'writes the image to out_dir with the label-based filename' do
        expect(csvout).to have_received(:write_to_file)\
          .with('./myfile.csv')
      end
    end

    context 'with no out_dir or filename' do
      before do
        @runner.write(result)
      end

      it 'creates an image of the simulation' do
        expect(image_maker).to have_received(:get_image).with(result)
      end

      it 'creates a csvoutput object with the simulation image' do
        expect(csvout_class).to have_received(:new).with(sim_image)
      end

      it 'writes the image to current dir with the label-based filename' do
        expect(csvout).to have_received(:write_to_file)\
          .with('./language_label.csv')
      end
    end
  end

  context 'when creating learning data' do
    let(:wlp10) { double('wlp10') }
    let(:wlp11) { double('wlp11') }
    let(:wlp20) { double('wlp20') }
    let(:win1) { double('win1') }
    let(:win2) { double('win2') }
    let(:output1) { double('output1') }
    let(:output2) { double('output2') }

    before do
      allow(wlp10).to receive(:winner).and_return(win1)
      allow(wlp11).to receive(:winner).and_return(win1)
      allow(wlp20).to receive(:winner).and_return(win2)
      allow(win1).to receive(:output).and_return(output1)
      allow(win2).to receive(:output).and_return(output2)
      lang = [wlp10, wlp11, wlp20]
      @data = described_class.wlp_to_learning_data(lang)
    end

    it 'returns a list of the outputs with no duplicates' do
      expect(@data).to contain_exactly(output1, output2)
    end
  end

  context 'when reading languages via class method' do
    it 'yields the label and outputs of each language' do
      dfile = File.join(ODL::DATA_DIR, 'sl', 'test_languages.mar')
      expect { |probe| described_class.read_languages(dfile, &probe) }.to \
        yield_successive_args(%w[TL1 Toutputs1], %w[TL2 Toutputs2])
    end
  end

  context 'when reading languages via instance method' do
    it 'yields the label and outputs of each language' do
      dfile = File.join(ODL::DATA_DIR, 'sl', 'test_languages.mar')
      expect { |probe| @runner.read_languages(dfile, &probe) }.to \
        yield_successive_args(%w[TL1 Toutputs1], %w[TL2 Toutputs2])
    end
  end
end

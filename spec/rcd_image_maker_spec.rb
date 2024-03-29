# frozen_string_literal: true

# Author: Bruce Tesar

require 'rcd_image_maker'

RSpec.describe RcdImageMaker do
  let(:rcd_result) { double('rcd_result') }
  let(:ct_image_maker) { double('ct_image_maker') }
  let(:ct_image) { double('ct_image') }
  let(:sheet_class) { double('sheet class') }
  let(:sheet) { double('sheet') }

  before do
    stub_const 'ML', QuickErc::ML
    stub_const 'ME', QuickErc::ME
    stub_const 'MW', QuickErc::MW
    allow(sheet_class).to receive(:new).and_return(sheet)
    allow(sheet).to receive(:put_range)
    allow(ct_image_maker).to receive(:get_image).and_return(ct_image)
    @rcd_image_maker = described_class.new(ct_image_maker: ct_image_maker,
                                           sheet_class: sheet_class)
  end

  context 'with RCD result with one ERC [W]' do
    let(:erc1) { QuickErc.new([MW]) }
    let(:unsorted_constraints) { erc1.constraint_list }
    let(:con1) { unsorted_constraints[0] }
    let(:sorted_ercs) { [erc1] }
    let(:sorted_constraints) { [con1] }

    before do
      allow(rcd_result).to receive(:hierarchy).and_return([[con1]])
      allow(rcd_result).to receive(:erc_list).and_return([erc1])
      @rcd_image = @rcd_image_maker.get_image(rcd_result)
    end

    it 'puts the CT image on the RCD image' do
      expect(@rcd_image).to have_received(:put_range).exactly(1).times
    end

    it 'constructs a CT image with one constraint and one erc' do
      expect(ct_image_maker).to\
        have_received(:get_image).with(sorted_ercs, sorted_constraints)
    end
  end

  context 'with erc_sort flag set to true' do
    let(:erc1) { QuickErc.new([ML, ME, MW]) }
    let(:erc2) { QuickErc.new([MW, MW, ML]) }
    let(:unsorted_ercs) { [erc1, erc2] }
    let(:unsorted_constraints) { erc1.constraint_list }
    let(:con1) { unsorted_constraints[0] }
    let(:con2) { unsorted_constraints[1] }
    let(:con3) { unsorted_constraints[2] }
    # Expected return values
    let(:sorted_ercs) { [erc2, erc1] }
    let(:sorted_constraints) { [con2, con3, con1] }

    before do
      allow(rcd_result).to\
        receive(:hierarchy).and_return([[con2], [con3], [con1]])
      allow(rcd_result).to receive(:erc_list).and_return(unsorted_ercs)
    end

    context 'with erc_sort set to true' do
      before do
        @rcd_image = @rcd_image_maker.get_image(rcd_result, erc_sort: true)
      end

      it 'puts the CT image on the RCD image' do
        expect(@rcd_image).to have_received(:put_range).exactly(1).times
      end

      it 'constructs a CT image with properly sorted ercs and constraints' do
        expect(ct_image_maker).to\
          have_received(:get_image).with(sorted_ercs, sorted_constraints)
      end
    end

    context 'with erc_sort false (not set)' do
      before do
        @rcd_image = @rcd_image_maker.get_image(rcd_result)
      end

      it 'puts the CT image on the RCD image' do
        expect(@rcd_image).to have_received(:put_range).exactly(1).times
      end

      it 'constructs a CT image with properly sorted ercs and constraints' do
        expect(ct_image_maker).to\
          have_received(:get_image).with(unsorted_ercs, sorted_constraints)
      end
    end
  end
end

# Author: Bruce Tesar

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'erc_list'

RSpec.fdescribe Erc_list do
  context "An empty Erc_list" do
    before(:each) do
      @erc_list = Erc_list.new
    end

    it "is empty" do
      expect(@erc_list.empty?).to be true
    end
    it "has size 0" do
      expect(@erc_list.size).to eq(0)
    end
    it "returns an empty list of constraints" do
      expect(@erc_list.constraint_list).to be_empty
    end
  end
  
  context "An Erc_list with one added erc" do
    before(:each) do
      @erc_list = Erc_list.new
      @erc1 = double("erc1")
      allow(@erc1).to receive(:constraint_list).and_return(["C1","C2"])
      allow(@erc1).to receive(:test_any).and_return(true)
      @erc_list.add(@erc1)
    end
    
    it "is not empty" do
      expect(@erc_list.empty?).not_to be true
    end
    it "has size 1" do
      expect(@erc_list.size).to eq(1)
    end
    it "returns the constraints of the erc" do
      expect(@erc_list.constraint_list).to contain_exactly("C1","C2")
    end
    it "returns true when #any? is satisfied by the erc" do
      expect(@erc_list.any?{|e| e.test_any}).to be true
    end
    it "returns false when #any? isn't satisfied by the erc" do
      expect(@erc_list.any?{|e| e.nil?}).to be false
    end
    
    context "and a second erc with the same constraints is added" do
      before(:each) do
        @erc2 = double("erc2")
        allow(@erc2).to receive(:constraint_list).and_return(["C2","C1"])
        allow(@erc2).to receive(:test_any).and_return(false)
        @erc_list.add(@erc2)
      end
      it "has size 2" do
        expect(@erc_list.size).to eq(2)
      end
      it "returns the constraints of the ercs" do
        expect(@erc_list.constraint_list).to contain_exactly("C1","C2")
      end
      it "returns true when #any? is satisfied by one of the ercs" do
        expect(@erc_list.any?{|e| e.test_any}).to be true
      end
      it "returns false when #any? isn't satisfied by any of the ercs" do
        expect(@erc_list.any?{|e| e.nil?}).to be false
      end
    end
    
    context "and a second erc with different constraints is added" do
      before do
        @erc_diff = instance_double(Erc)
        allow(@erc_diff).to receive(:constraint_list).and_return(["C3","C4"])
      end
      it "raises a RuntimeError" do
        expect{@erc_list.add(@erc_diff)}.to raise_exception(RuntimeError)
      end
    end

    context "and a second erc with a different number of constraints is added" do
      before do
        @erc_diff = instance_double(Erc)
        allow(@erc_diff).to receive(:constraint_list).and_return(["C1","C2","C3"])
      end
      it "raises a RuntimeError" do
        expect{@erc_list.add(@erc_diff)}.to raise_exception(RuntimeError)
      end
    end
  end
end # describe Erc_list


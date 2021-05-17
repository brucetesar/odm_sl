# frozen_string_literal: true

# Author: Bruce Tesar
#
# These specs verify that the standard library class Set is hashable in
# the expected manner: two distinct sets with equivalent members should be
# treated as equivalent sets, and should be assigned the same hash value.
# In early implementations of Ruby (including 1.8.6), Set did not meet
# these requirements.
#
# The class Set contains an instance of class Hash. At the time, Hash itself
# did not implement the methods hash() and eql?(), so they defaulted
# to the versions defined in class Object. As a consequence, two hashes were
# eql only if they were the same object, normally, and the hash() values
# assigned to them were equal only if they were the same object. The class Set
# also did not implement hash() and eql?(), and inherited this odd behavior.
# Later implementations of Ruby fixed this shortcoming, so that instances
# of Set are hashable. These specs verify that Set behaves as expected.

require 'set'

RSpec.shared_examples 'equivalent sets' do
  it 'are equivalent' do
    expect(set1 == set2).to be true
  end
  it 'are not the same object' do
    expect(set1.equal?(set2)).not_to be true
  end
  it 'are eql' do
    expect(set1.eql?(set2)).to be true
  end
  it 'have the same hash value' do
    expect(set1.hash).to equal(set2.hash)
  end
end

RSpec.shared_examples 'non-equivalent sets' do
  it 'are not equivalent' do
    expect(set1 == set2).not_to be true
  end
  it 'are not the same object' do
    expect(set1.equal?(set2)).not_to be true
  end
  it 'are not eql' do
    expect(set1.eql?(set2)).not_to be true
  end
  it 'do not have the same hash value' do
    expect(set1.hash).not_to equal(set2.hash)
  end
end

RSpec.describe Set do
  context 'distinct sets' do
    before(:each) do
      @sh1 = Set.new
      @sh2 = Set.new
    end

    context 'each with no members' do
      it_behaves_like 'equivalent sets' do
        let(:set1) { @sh1 }
        let(:set2) { @sh2 }
      end
    end

    context "each with 'foobar'" do
      it_behaves_like 'equivalent sets' do
        let(:set1) { @sh1.add 'foobar' }
        let(:set2) { @sh2.add 'foobar' }
      end
    end

    context "one with 'foo' and one with 'bar'" do
      it_behaves_like 'non-equivalent sets' do
        let(:set1) { @sh1.add 'foo' }
        let(:set2) { @sh2.add 'bar' }
      end
    end
  end
end

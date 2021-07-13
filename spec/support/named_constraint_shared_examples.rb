# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'

# When invoked in RSpec via it_behaves_like, a block must be provided that
# uses let() statements define three arguments:
# * con - a reference constraint
# * eq_con - a constraint token-distinct from con, but with the same name.
# * noteq_con - a constraint with a different name from con.
RSpec.shared_examples 'named constraint' do
  it 'is == to another constraint with the same name' do
    expect(con == eq_con).to be true
  end

  it 'is eql? to another constraint with the same name' do
    expect(con.eql?(eq_con)).to be true
  end

  it 'has the same hash value as a same-named constraint' do
    expect(con.hash).to eq(eq_con.hash)
  end

  it 'is not == to a constraint with a different name' do
    expect(con == noteq_con).to be false
  end

  it 'is not eql? to a constraint with a different name' do
    expect(con.eql?(noteq_con)).to be false
  end

  it 'does not have the same hash value as a diff-named constraint' do
    expect(con.hash).not_to eq(noteq_con.hash)
  end
end

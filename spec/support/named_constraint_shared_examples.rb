# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'

# When invoked in RSpec via it_behaves_like, a block must be provided that
# uses let() statements define three arguments:
# * con - a reference constraint
# * eq_con - a constraint token-distinct from con, but with the same name.
# * noteq_con - a constraint with a different name from con.
# * not_a_con - an object that is not a constraint; in particular, it does
#   not respond to the #symbol method.
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

  # This addresses a bug that surfaced when using Psych to deserialize
  # Constraint objects from a .yml file. Psych at one point compares
  # a hash key (in this instance, a Constraint) to a special string
  # (in this instance, '<<'), by calling #== on the constraint. The method
  # Constraint#== calls #symbol on its parameter to compare the symbols,
  # but strings (and many other things) don't have a #symbol method.
  # This test ensures that any parameter object is checked to see if it
  # responds to #symbol, and if it doesn't, false is returned, because
  # a non-constraint cannot be equivalent to a constraint.
  it 'is not equal to an object that does not respond to #symbol' do
    expect(con == not_a_con).to be false
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

# A candidate has an input, an output, and a violation count for each
# constraint. It also has a list of the constraints in the system.
class Candidate
  # The input form
  attr_accessor :input

  # The output form
  attr_accessor :output

  # The label of the candidate (often the candidate number)
  attr_accessor :label

  # The candidate is initialized with violation counts assigned for any of
  # the constraints. At the least, violation counts must be
  # subsequently assigned to each constraint via set_viols().
  #
  # ==== Parameters
  #
  # * +input+ - the input structure
  # * +output+ - the output structure
  # * +constraints+ - a list of the constraint objects for the system; must
  #   be convertible to Array via +constraints.to_a+.
  #
  # :call-seq:
  #   Candidate.new(input, output, constraints) -> candidate
  def initialize(input, output, constraints)
    @input = input
    @output = output
    @constraints = constraints.to_a # make sure the list is an array.
    @violations = {}
  end

  # Returns a copy of the candidate, containing duplicates of the
  # input and the output.
  # The copy candidate also gets a duplicate of the constraint violations.
  def dup
    copy = Candidate.new(@input.dup, @output.dup, @constraints)
    @constraints.each { |con| copy.set_viols(con, get_viols(con)) }
    copy
  end

  # Freezes the candidate, and also freeze's the candidates input, output,
  # and violation counts.
  # Returns a reference to self.
  def freeze
    super
    @input.freeze
    @output.freeze
    @violations.freeze
    self
  end

  # Returns true if +con+ is in the candidate's constraint list;
  # returns false otherwise.
  def con?(con)
    @constraints.include?(con)
  end

  # Returns a reference to the constraint list of the candidate.
  #
  # *WARNING*: altering the list returned from this method will alter
  # the state of this object.
  #--
  # The idea is to have a single constraint list object shared by all other
  # objects in the system (more efficient).
  #++
  def constraint_list
    @constraints
  end

  # Sets the number of violations of constraint +con+ to the value
  # +violation_count+. Returns the number of violations.
  def set_viols(con, violation_count)
    @violations[con] = violation_count
  end

  # Returns the number of violations assessed to this candidate by
  # constraint +con+.
  def get_viols(con)
    @violations[con]
  end

  # Returns true if this candidate has an identical violation profile to
  # +other+; returns false otherwise.
  def ident_viols?(other)
    @constraints.all? do |con|
      self.get_viols(con) == other.get_viols(con)
    end
  end

  # Compares this candidate with +other+ for value equality, with respect
  # to their inputs and their outputs. It ignores the violations, as
  # these should automatically be identical if the input and output are
  # the same.
  def ==(other)
    return false unless input == other.input
    return false unless output == other.output

    true
  end

  # The same as ==
  def eql?(other)
    self == other
  end

  # Represent the candidate with a string.
  # * The input and output strings, separated by " --> "
  # * A list of constraints and the number of violations of each.
  #   If a constraint hasn't been assigned a violation count, display '?'.
  def to_s
    viol_s = ' '
    @constraints.each do |c|
      if @violations.key?(c) # if c has been assigned a violation count
        viols_c = get_viols(c)
      else
        viols_c = '?'
      end
      viol_s += " #{c}:#{viols_c}"
    end
    output_s = @output.to_s
    "#{@input} --> #{output_s} #{viol_s}"
  end

  # Returns an array a of the elements of the candidate, all
  # represented as strings. This is used when presenting the
  # candidate in a sequence of cells.
  # * a[0] - input
  # * a[1] - output
  # * a[2 thru 2+con_count-1] - violations of each constraint
  def to_a
    ca = []
    ca[0] = @input.to_s
    ca[1] = @output.to_s
    col = 2
    @constraints.each do |c|
      ca[col] = @violations[c]
      col += 1
    end
    ca
  end
end

# Author: Bruce Tesar

# A candidate has an input, an output, and a violation count for each
# constraint. Finally,
# a candidate has a list of the constraints in the system, a label, and
# a remarks string.
class Candidate
  # The input form
  attr_accessor :input

  # The output form
  attr_accessor :output

  # The label of the candidate (often the candidate number)
  attr_accessor :label

  # An optional string for incidental comments on the candidate
  attr_accessor :remark

  # Create a candidate from the given parameters.
  # The candidate is initialized with no label, no remark, no violation
  # counts assigned for any of the constraints,
  # and it is not a merged candidate. At the least, violation counts
  # must be subsequently assigned to each constraint via set_viols().
  #
  # ==== Parameters
  #
  # * +input+ - the input structure
  # * +output+ - the output structure
  # * +constraints+ - a list of the constraint objects for the system; must
  #   be convertible to Array via +constraints.to_a+.
  #
  def initialize(input, output, constraints)
    @input = input
    @output = output
    @constraints = constraints.to_a # make sure the list is an array.
    @violations = {}
    @label = nil
    @remark = nil
    # Initially, a candidate has no merged candidates (ones with identical violations).
    @merged = false
    @merge_candidates = []
  end

  # Returns a copy of the candidate, containing duplicates of the
  # input, the output, label, remark, and the list of merged candidates
  # (the merged candidates themselves are not duplicated).
  # The copy candidate also gets a duplicate of the constraint violations.
  def dup
    copy = Candidate.new(@input.dup, @output.dup, @constraints)
    @constraints.each { |con| copy.set_viols(con, get_viols(con)) }
    copy.label = @label.dup unless @label.nil? # cannot call nil.dup()
    copy.remark = @remark.dup unless @remark.nil?
    # set @merged of the copy to be the same as @merged of the current candidate.
    copy.instance_variable_set(:@merged, @merged)
    # set @merged_candidates of the copy to be A DUPLICATE of
    # @merged_candidates of the current candidate.
    copy.instance_variable_set(:@merge_candidates, @merge_candidates.dup)
    copy
  end

  # Freezes the candidate, and also freeze's the candidates input, output,
  # violation counts, and merged candidate list.
  # Returns a reference to self.
  def freeze
    super
    @input.freeze
    @output.freeze
    @violations.freeze
    @merge_candidates.freeze
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

  # Returns true if the candidate harmonically bounds +other+.
  # Returns false if +other+ harmonically
  # bounds this candidate, or if neither harmonically bounds the other.
  #
  # One candidate harmonically bounds another if the first
  # candidate is preferred (has fewer violations) by at least one constraint,
  # and the other candidate is not preferred by any constraint.
  def harmonically_bounds?(other)
    better_on_a_constraint = false
    worse_on_a_constraint = false
    @constraints.each do |con|
      if self.get_viols(con) < other.get_viols(con)
        better_on_a_constraint = true
      end
      if self.get_viols(con) > other.get_viols(con)
        worse_on_a_constraint = true
      end
    end
    better_on_a_constraint && !worse_on_a_constraint
  end

  # Compares this candidate with +other+ for value equality, with respect
  # to their inputs and their outputs. It ignores the label
  # and remark, as well as the violations (these should automatically be
  # identical if the inputs have the same value and the outputs have the
  # same value).
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
  # * The candidate's label.
  # * The input and output strings, separated by " --> "
  # * A list of constraints and the number of violations of each.
  #   If a constraint hasn't been assigned a violation count, display '?'.
  # * The remark, if any.
  # * If this is a merged candidate, the outputs of the individual
  #   merge candidates are listed, one per line.
  def to_s
    if @label
      label_s = "#{@label}: "
    else
      label_s = ''
    end
    viol_s = ' '
    @constraints.each do |c|
      if @violations.key?(c) # if c has been assigned a violation count
        viols_c = get_viols(c)
      else
        viols_c = '?'
      end
      viol_s += " #{c}:#{viols_c}"
    end
    if @remark
      remark_s = "  #{@remark}"
    else
      remark_s = ''
    end
    output_s = @output.to_s
    merge_s = ''
    @merge_candidates.each { |c| merge_s += "\n --> #{c.output}" }
    "#{label_s}#{@input} --> #{output_s} #{viol_s}#{remark_s}#{merge_s}"
  end

  # Returns a string with the +to_s+ of the output of each merged candidate,
  # separated by " MER ". If there are no merge candidates, simply returns
  # the to_s() of the (single) output.
  def merged_outputs_to_s
    full_s = @output.to_s
    @merge_candidates.each { |c| full_s += " MER #{c.output}" }
    full_s
  end

  # Returns an array a of the elements of the candidate, all
  # represented as strings. This is used when presenting the
  # candidate in a sequence of cells.
  # * a[0] - label
  # * a[1] - input
  # * a[2] - output
  # * a[3 thru 3+con_count-1] - violations of each constraint
  # * a[3+con_count] - remark
  def to_a
    ca = []
    ca[0] = @label.to_s
    ca[1] = @input.to_s
    ca[2] = @output.to_s
    col = 3
    @constraints.each do |c|
      ca[col] = @violations[c]
      col += 1
    end
    ca[3 + @constraints.size] = @remark
    ca
  end
end

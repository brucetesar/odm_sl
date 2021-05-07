# frozen_string_literal: true

# Author: Bruce Tesar

# A basic OT constraint, consisting of a name, an id, a type, and an
# evaluation procedure for assigning violations to candidates.
# Only the name is compared when constraints are compared for equality.
# The id is an abbreviated label used for constructing labels for
# complex objects. If nil is provided as the ID parameter, then no ID
# is used.
#
# Constraints are used as keys for hashes (e.g., in ercs), so they should
# not be altered once constructed. It is a good idea to freeze the
# constraint objects once they have been created.
# Ideally, any OT system or analysis should have just a single object for
# each constraint, with all constraint-referring objects containing
# references to those same constraints.
class Constraint
  # the markedness constraint type constant
  MARK  = :markedness

  # the faithfulness constraint type constant
  FAITH = :faithfulness

  # The name of the constraint.
  attr_reader :name

  # The symbol version of the constraint's name.
  attr_reader :symbol

  # TODO: eliminate Constraint id (affects fixtures, ::new()).
  # The id (an abbreviated label) of the constraint.
  attr_reader :id

  # Returns a new constraint object.
  # === Parameters
  # * _name_ - the name of the constraint.
  # * _id_ - an abbreviated label.
  # * _type_ - type of constraint; must be one of the type constants.
  #   * Constraint::FAITH    faithfulness constraint
  #   * Constraint::MARK     markedness constraint
  # * The block parameter is the violation evaluation function; it should
  #   take, as a parameter, a candidate, and return the number of times
  #   that candidate violates this constraint.
  # Raises a RuntimeError if _type_ is not one of the type constants.
  # :call-seq:
  #   Constraint.new(name, id, type) {|constraint| ... } -> constraint
  def initialize(name, id, type, &eval)
    @name = name.freeze
    @symbol = name.to_sym
    # The name should never change, so calculate the hash value of the
    # name once and store it.
    @hash_value = @name.hash
    @id = id.to_s unless id.nil?
    check_constraint_type(type)
    # store the evaluation function (passed as a code block)
    @eval_function = eval
  end

  # Makes sure that _type_ is one of the constraint type constants;
  # raises a RuntimeError if it isn't.
  # Pre-computes a boolean indicating if the constraint is a markedness
  # constraint or not.
  def check_constraint_type(type)
    if type == MARK
      @markedness = true
    elsif type == FAITH
      @markedness = false
    else
      raise "Type must be either MARK or FAITH, cannot be #{type}"
    end
  end
  private :check_constraint_type

  # Two constraints are equivalent if their names are equivalent.
  def ==(other)
    # Comparing two symbols is faster than comparing two strings.
    @symbol == other.symbol
  end

  # The same as ==
  def eql?(other)
    self == other
  end

  # Returns the hash number of the constraint. The hash number
  # for a constraint is the hash number of its name. If two
  # constraints have the same name, they will have the same hash number.
  def hash
    @hash_value
  end

  # Returns true if this is a markedness constraint, and false otherwise.
  def markedness?
    @markedness
  end

  # Returns true if this is a faithfulness constraint, and false
  # otherwise.
  def faithfulness?
    !@markedness
  end

  # Returns the number of times this constraint is violated by the
  # parameter candidate.
  # Raises a RuntimeError if no evaluation function block was provided
  # at the time the constraint was constructed.
  def eval_candidate(cand)
    if @eval_function.nil?
      msg = 'Constraint#eval_candidate: no evaluation function' \
            ' was provided but #eval_candidate was called.'
      raise msg
    end

    @eval_function.call(cand) # call the stored code block.
  end

  # Returns a string consisting of the constraint's id, followed
  # by a colon, followed by the constraint's name.
  def to_s
    if @id.nil?
      @name.to_s
    else
      "#{@id}:#{@name}"
    end
  end
end

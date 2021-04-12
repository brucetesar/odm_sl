# frozen_string_literal: true

# Author: Bruce Tesar

# An Arg Checker provides methods useful in validating the values
# that should be provided through command like arguments.
class ArgChecker
  # Returns a new object of class ArgChecker.
  # :call-seq:
  #   ArgChecker.new -> checker
  def initialize; end

  # Checks if _arg_ is given (not nil). If it is, return true.
  # If _arg_ is nil, print an error message including the name string
  # of the missing option, and return false.
  # :call-seq:
  #   any_given?(arg, option_string) -> boolean
  def arg_given?(arg, option_string)
    return true unless arg.nil?

    puts "ERROR: missing command line option #{option_string}."
    false
  end

  # Checks if _arg_ has a valid value, i.e., is a member of _values_.
  # If _arg_ is a member of _values_, return true.
  # If _arg_ is not given (nil), print an error message and return false.
  # If _arg_ is not nil, but not a member of _values_, print an error
  # message and return false.
  # :call-seq:
  #   arg_valid?(arg, values, option_string) -> boolean
  def arg_valid?(arg, values, option_string)
    return true if values.member?(arg)
    return false unless arg_given?(arg, option_string)

    puts "ERROR: invalid #{option_string} value #{arg}."
    puts "Value must be one of #{values.join(', ')}"
    false
  end
end

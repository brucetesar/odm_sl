# frozen_string_literal: true

# Author: Bruce Tesar

# An Arg Checker provides methods useful in validating the values
# that should be provided through command like arguments.
class ArgChecker
  # Returns a new object of class ArgChecker.
  # :call-seq:
  #   ArgChecker.new -> checker
  #--
  # err_output is a dependency injection used for testing. It is
  # the IO channel to which error msgs are written (normally $stderr).
  def initialize(err_output: $stderr)
    @err_output = err_output
  end

  # Checks if _arg_ is given (not nil). If it is, return true.
  # If _arg_ is nil, print an error message including the name string
  # of the missing option, and return false.
  # :call-seq:
  #   any_given?(arg, option_string) -> boolean
  def arg_given?(arg, option_string)
    return true unless arg.nil?

    @err_output.puts "ERROR: missing command line option #{option_string}."
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

    @err_output.puts "ERROR: invalid #{option_string} value #{arg}."
    @err_output.puts "Value must be one of #{values.join(', ')}"
    false
  end
end

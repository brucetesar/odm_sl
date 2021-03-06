# frozen_string_literal: true

# Author: Bruce Tesar

# A FeatureValuePair is a specific feature instance, paired with
# a *possible* value for the feature, called the _alt_value_.
# The point is to be able to
# store and reason with possible values for particular feature instances
# without having to actually set the given feature instance to that value.
# This is useful for representing things like possible combinations of
# values for features; a particular combination can be represented as
# a list of Feature Value Pairs, allowing one to simultaneously represent
# multiple such combinations. At any desired time, a feature instance
# can be set to the associated alt_value with #set_to_alt_value.
class FeatureValuePair
  # The feature instance represented by this pair.
  attr_reader :feature_instance

  # The feature value represented by this pair.
  attr_reader :alt_value

  # Returns a FeatureValuePair with feature instance _feature_instance_ and
  # alt_value _value_.
  def initialize(feature_instance, value)
    verify_value(feature_instance, value)
    @feature_instance = feature_instance
    @alt_value = value
  end

  # Sets the value of the feature instance of this pair to the alt_value
  # of this pair.
  def set_to_alt_value
    @feature_instance.feature.value = @alt_value
  end

  # Verify that _value_ is a possible value of _feature_instance_.
  # Raises a RuntimeError exception if the value is not valid.
  def verify_value(feature_instance, value)
    feature = feature_instance.feature
    msg1 = "Feature value #{value}"
    msg2 = "is not a possible value for #{feature.type}"
    raise "#{msg1} #{msg2}" unless feature.valid_value?(value)
  end
  private :verify_value
end

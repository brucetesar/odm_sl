# frozen_string_literal: true

# Author: Bruce Tesar

module ODL
  # Element generators will generate the possible distinct element values.
  # A possible element value is a possible combination of values of the
  # features of the element. This is useful for things like generating
  # all possible underlying forms for a lexical entry.
  class ElementGenerator
    # Returns a new element generator.
    # === Parameters
    # * element_class - the class of objects implementing the element.
    #   _new_() is called on the element_class to get an element instance;
    #   further instances are created from the first via _dup_().
    # :call-seq:
    #   new(element_class) -> generator
    def initialize(element_class)
      @element_class = element_class
    end

    # Returns an array of elements, one for each possible combination
    # of values of the features of the element.
    # :call-seq:
    #   elements() -> array
    def elements
      start_el = @element_class.new
      el_list = [start_el]
      # for each feature, create a "cartesian product" of that feature's
      # values and the existing elements.
      start_el.each_feature do |f|
        el_list = feature_values_product(f, el_list)
      end
      # If a code block is given, run it on each element.
      el_list.each { |e| yield e } if block_given?
      el_list
    end

    # Generates the possible values of _feature_, and then creates
    # a separate copy of each element of _el_list_ for each value of
    # _feature_, with the element's instance of _feature_ set to
    # its corresponding feature value.
    # Returns an array of the constructed elements.
    def feature_values_product(feature, el_list)
      product_list = []
      feature.each_value do |v|
        el_list.each do |e|
          el = e.dup
          f_of_el = el.get_feature(feature.type)
          f_of_el.value = v
          product_list << el
        end
      end
      product_list
    end
    private :feature_values_product
  end
end

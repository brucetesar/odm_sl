# frozen_string_literal: true

# Author: Bruce Tesar

require 'underlying'

module ODL
  # Underlying form generators generate lists of underlying forms meeting
  # specified criteria, such as all underlying forms having a specified
  # length (number of basic elements).
  #
  # The concept of "basic element" here is normally expected to be the
  # unit of representation that stands in correspondence with similar
  # units of inputs and outputs. For instance, in the SL linguistic
  # system, the basic element is the syllable, and the IO correspondence
  # relation relates input syllables and output syllables, hence the UI
  # correspondence relation relates underlying form syllables and input
  # syllables.
  class UnderlyingFormGenerator
    # Returns a new underlying form generator.
    # === Parameters
    # * element_generator - generates all possible underlying form
    #   elements (e.g., syllables). Must implement a method #elements
    #   that accepts a code block and yields each possible element
    #   to it.
    # :call-seq:
    #   new(element_generator) -> generator
    def initialize(element_generator)
      @element_generator = element_generator
    end

    # Returns an array of underlying forms, all of the possible
    # UFs with _length_ elements.
    #
    # Raises a RuntimeError if _length_ is negative.
    # :call-seq:
    #   underlying_forms(length) -> array
    def underlying_forms(length)
      raise 'UF length cannot be negative!' if length < 0

      # Start with a single empty underlying form
      uf_list = [Underlying.new]
      # Add underlying elements as many times as the length
      length.times { uf_list = extend_ufs(uf_list) }
      # If a code block is given, run it on each underlying form.
      uf_list.each { |uf| yield uf } if block_given?
      uf_list
    end

    # Given a list of UFs, create copies of each UF, one per possible
    # element, extending each copy with a distinct additional element.
    def extend_ufs(uf_list)
      new_uf_list = []
      uf_list.each do |uf|
        # create a copy of uf for possible element,
        # extended by that element.
        @element_generator.elements do |e|
          new_uf_list << (uf.dup << e)
        end
      end
      new_uf_list
    end
    private :extend_ufs
  end
end

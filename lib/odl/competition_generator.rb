# frozen_string_literal: true

# Author: Bruce Tesar

module ODL
  # A competition generator can take a list of morphwords and return
  # a corresponding list of competitions. The generator is passed
  # a reference to a linguistic system at construction time. When
  # the method call competitions(words, lexicon) is made, it maps
  # each morphword to a corresponding input using the underlying forms
  # provided in _lexicon_, and then in turn maps each such input to
  # its corresponding competition of candidates.
  #
  # The generator assumes that the provided _lexicon_ contains lexical
  # entries for all of the morphemes referenced in the morphwords, and
  # that all such lexical entries have fully specified underlying forms.
  class CompetitionGenerator
    # Returns a new competition generator.
    # === Parameters
    # * system - the linguistic system which governs the structure of
    #   morphwords, provides the _input_from_morphword_ method, and
    #   provides the _gen_ method mapping an input to a competition.
    # :call-seq:
    #   new(system) -> generator
    def initialize(system)
      @system = system
    end

    # Returns an array of competitions, one for each morphword in _mwords_.
    # Each competition is based on the corresponding morphword's input
    # as constructed via the lexical entries in _lexicon_.
    # :call-seq:
    #   competitions(mwords, lexicon) -> array
    def competitions(mwords, lexicon)
      inputs = mwords.map { |mw| @system.input_from_morphword(mw, lexicon) }
      inputs.map { |i| @system.gen(i) }
    end
  end
end

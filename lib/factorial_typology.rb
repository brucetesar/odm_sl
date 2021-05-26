# frozen_string_literal: true

# Author: Bruce Tesar

require 'erc_list'
require 'harmonic_bound_filter'
require 'ident_violation_analyzer'
require 'labeled_object'
require 'psych'

# FactorialTypology objects summarize typologies of competition lists
# in several ways:
# * A list, for each competition, of contender candidates (possibly
#   optimal). See attribute #contender_comp_list.
# * A list, for each language, of winner-loser pairs, with each winner
#   paired separately with each of its competing contenders.
#   See attribute #ranking_ercs_lists.
# * A list, for each language, of the winning candidates.
#   See attribute #winner_lists.
# * A list, for each language, of the outputs of the winning candidates.
#   See attribute #learning_data.
# The languages are assigned numbered label strings, in the order in
# which they are generated: L1, L2, and so forth. The elements of the
# lists returned by #ranking_ercs_lists, #winner_lists, and #learning_data
# all respond to the method _#label_ with the numbered language label string.
class FactorialTypology
  # The list of competitions with all the candidates
  attr_reader :original_comp_list

  # The list of competitions with only contenders (non-harmonically bound)
  attr_reader :contender_comp_list

  # A list of the languages, each language represented as a list of
  # winner-loser pairs, one for each combination of a winner and
  # a contending competitor.
  attr_reader :ranking_ercs_lists

  # A list of the languages, each language represented as a list of the
  # winners for that language.
  attr_reader :winner_lists

  # A list of the languages, each language represented as a list of the
  # outputs of the winners for that language.
  attr_reader :learning_data

  # Returns an object summarizing the factorial typology of the parameter
  # _competition_list_. The parameter _competition_list_ must respond to
  # the method #each.
  #
  # :call-seq:
  #   new(competition_list) -> typology
  #--
  # erc_list_class, hbound_filter, and viol_analyzer_class are dependency
  # injections, used for testing.
  def initialize(competition_list, erc_list_class: nil,
                 hbound_filter: nil, viol_analyzer_class: nil)
    @original_comp_list = competition_list
    # Apply default values to dependency injections
    @erc_list_class = erc_list_class || ErcList
    @harmonic_bound_filter = hbound_filter || HarmonicBoundFilter.new
    @viol_analyzer_class = viol_analyzer_class || IdentViolationAnalyzer
    # Obtain the constraint list from the first candidate of the first
    # competition.
    @con_list = @original_comp_list.first.first.constraint_list
    # Filter out non-contender candidates, check for identical violations.
    @contender_comp_list = []
    filter_harmonically_bounded
    ident_viol_candidates_check
    compute_typology
  end

  # Internal class representing a language as a list of winners
  # along with a list of ERCs containing one ERC for each winner /
  # competitor pair.
  class LangRank # :nodoc:
    # List of the winners of the language.
    attr_accessor :winners

    # List of the ranking ERCs supporting the typology.
    attr_accessor :ercs

    # Returns a new LangRank object.
    def initialize(erc_list)
      @winners = []
      @ercs = erc_list
    end

    # Returns a duplicate of the LangRank object, which contains
    # a duplicate of the winners list and a duplicate of the ERCs list.
    def dup
      dup = super
      dup.winners = winners.dup
      dup.ercs = ercs.dup
      dup
    end
  end

  # Private method, called by #initialize, to filter out collectively
  # harmonically bound candidates, creating a list of competitions consisting
  # only of contenders.
  def filter_harmonically_bounded
    @original_comp_list.each do |comp|
      contenders = @harmonic_bound_filter.remove_collectively_bound(comp)
      @contender_comp_list << contenders
    end
  end
  private :filter_harmonically_bounded

  # Checks the competitions of contenders, raises an exception if two or more
  # competing contenders are found with identical constraint violation
  # profiles.
  def ident_viol_candidates_check
    msg = 'competing contenders with identical violation profiles'
    contender_comp_list.each do |comp|
      analysis = @viol_analyzer_class.new(comp)
      raise "FactorialTypology: #{msg}" if analysis.ident_viol_candidates?
    end
  end
  private :ident_viol_candidates_check

  # Computes the factorial typology and creates the representations of it.
  # Returns nil.
  def compute_typology
    # Construct initial language list with a single empty language.
    lang_list = [LangRank.new(@erc_list_class.new(@con_list))]
    # Iterate over the competitions
    contender_comp_list.each do |competition|
      lang_list_new = []
      lang_list.each do |lang|
        # test each candidate of competition as a possible winner with
        # the existing language.
        combinations = combine_and_test_winners(competition, lang)
        lang_list_new.concat(combinations)
      end
      lang_list = lang_list_new
    end
    create_representations(lang_list)
  end
  private :compute_typology

  # Combine each member of _competition_ as a winner with _lang_.
  # Return those combinations that are consistent.
  def combine_and_test_winners(competition, lang)
    consistent_comb = []
    competition.each do |winner|
      lang_new = lang.dup
      new_pairs = @erc_list_class.new_from_competition(winner,
                                                       competition)
      lang_new.winners << winner
      lang_new.ercs.add_all(new_pairs)
      # If the new language is consistent, add it to the new
      # language list.
      consistent_comb << lang_new if lang_new.ercs.consistent?
    end
    consistent_comb
  end
  private :combine_and_test_winners

  # Create the ranking erc, winners, and learning data representations
  # of the typology.
  def create_representations(lang_list)
    @ranking_ercs_lists = lang_list.map(&:ercs)
    label_languages(@ranking_ercs_lists)
    @winner_lists = lang_list.map { |lang| LabeledObject.new(lang.winners) }
    label_languages(@winner_lists)
    output_lists = @winner_lists.map { |win_list| win_list.map(&:output) }
    @learning_data = output_lists.map { |outs| LabeledObject.new(outs) }
    label_languages(@learning_data)
    nil
  end
  private :create_representations

  # Assign numbered labels to the languages, by the order in which they
  # appear in the language list. Each label is stored as the label
  # attribute of the corresponding language.
  # Returns a reference to the list of languages.
  #
  # Example: The label for the first language is L1.
  def label_languages(lang_list)
    lang_label = 0
    lang_list.each do |lang|
      lang_label += 1
      lang.label = "L#{lang_label}"
    end
    lang_list
  end
  private :label_languages

  # Write report files to _data_dir_, consisting of:
  # * learning data file, outputs_typology_<_suffix_>.yml
  # * lists of winners by language, lang_<_suffix_>/<lang.label>.txt
  # The _suffix_ is usually used to represent the kinds of morpheme
  # combinations present in _competition_list_, for example:
  # * 1r1s - each word consists of a 1 syllable root with a 1 syllable
  #   suffix.
  # :call-seq:
  #   write_to_files(data_dir, suffix) -> nil
  def write_to_files(data_dir, suffix)
    # Create the data directory if necessary.
    Dir.mkdir(data_dir) unless Dir.exist?(data_dir)
    # Set the lang directory; create it if necesary.
    lang_dir = File.expand_path("lang_#{suffix}", data_dir)
    Dir.mkdir(lang_dir) unless Dir.exist?(lang_dir)
    # Write human-readable files listing the winners for each of the
    # languages of the typology.
    write_language_reports(lang_dir)
    # Write the learning data for each language of the typology to a data
    # file. Uses Psych to write an object to file in YAML format.
    write_learning_data(data_dir, suffix)
  end

  # Write human-readable files listing the winners for each of the languages
  # of the typology.
  # :call-seq:
  #   write_language_reports(lang_dir) -> nil
  def write_language_reports(lang_dir)
    winner_lists.each do |lang|
      rpt_file = File.join(lang_dir, "#{lang.label}.txt")
      File.open(rpt_file, 'w') do |f|
        lang.each { |winner| f.puts winner.to_s }
      end
    end
    nil
  end

  # Write the learning data for each language of the typology to the data
  # file _data_dir_/outputs_typology_<_suffix_>.yml.
  # Uses Psych to write to file in YAML format.
  # :call-seq:
  #   write_learning_data(data_dir, suffix) -> nil
  def write_learning_data(data_dir, suffix)
    yml_file = File.join(data_dir, "outputs_typology_#{suffix}.yml")
    File.open(yml_file, 'w') do |f|
      Psych.dump(learning_data, f)
    end
    nil
  end
end

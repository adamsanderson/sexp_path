require 'parse_tree'

# See SexpQueryBuilder.wild and SexpQueryBuilder._
class SexpPath::Matcher::RubyFragment < SexpPath::Matcher::Base
  PLACEHOLDER_REGEXP = /\(\(([A-Z_]+)\)\)/.freeze
  
  attr_reader :fragment
  attr_reader :fragment_sexp
  
  def initialize(fragment)
    initial_fragment = fragment

    parser = ParseTree.new()
    fallbacks = [:with_closing_end, :with_closing_brace]

    @fragment_sexp = Sexp.from_array(parser.parse_tree_for_string(fragment))
    @fragment = fragment
    replace_placeholders!
  end
  
  # Match against the generated fragment sexp.
  def satisfy?(o, data={})
    fragment_sexp.satisfy? o, data
  end

  def inspect
    "rb(#{fragment_sexp.inspect})"
  end
  
  private

  def placeholder_values
    values = []
    fragment.scan(PLACEHOLDER_REGEXP){|m| values << m.first}
    values.uniq.map{|v| v.to_sym}
  end
  
  def replace_placeholders!
    placeholder_values.each do |value|
      name = value.to_s.downcase
      placeholder_sexp = s(:const, value)
      fragment_sexp.replace_sexp(placeholder_sexp) do |match|
        Q?{ _ % name}
      end
    end
  end
end
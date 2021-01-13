require 'logger'
require 'parser/current'

class Rubidex::Indexer < Parser::AST::Processor
  attr_accessor :symbols
  def initialize(index, path, logger:)
    @index = index
    @path = path
    @logger = logger
    @symbols = []
  end

  def process(node)
    return if node.nil?

    @logger.debug "Processing #{node.type} Node"
    super(node)
  end

  def on_begin(node)
    node.children.each do |child|
      process child
    end
  end

  def on_module(node)
    location = node.location.keyword.join(node.location.name)
    symbol = define(node.children[0], location, :module, :definition)
    process_children symbol, node.children.drop(1)
  end

  def on_class(node)
    location = node.location.keyword.join(node.location.name)
    symbol = define(node.children[0], location, :class, :definition)

    define(node.children[1], location, :class, :reference) unless node.children[1].nil?

    process_children symbol, node.children.drop(2)
  end

  def on_send(node)
    process node.children[0] unless node.children[0].nil?
    define(node, node.location.expression, :call, :reference)
  end

  def on_const(node)
    define(node, node.location.expression, :const, :reference)
  end

  def handler_missing(node)
    @logger.debug "No handler for #{node.type} node."
  end

  private
 
  UNDEFINABLE_SYMBOLS = [:array].freeze
  def define(node, location, symbol_type, reference_type)
    case node&.type
    when :const
      parent = if node.children[0].nil?
                 @parent_symbol if reference_type == :definition
               else
                 define(node.children[0], node.children[0].location.expression, symbol_type, :reference) unless node.children[0].nil?
               end
      name = node.children[1]
    when :send
      name = node.children[1]
    when :lvar, :ivar
      name = node.children[0]
    else
      warn "Encountered unexpected undefinable symbol of type #{node&.type}" unless UNDEFINABLE_SYMBOLS.include?(node&.type)
      # No-op, we can't define this symbol
      return
    end

    defn = Rubidex::Reference::new(@path, location, reference_type)
    sym = @index.define_symbol(node.children[1], parent, symbol_type, defn)
    sym
  end

  def process_children(new_parent, children)
    old_parent = @parent_symbol
    begin
      @parent_symbol = new_parent
      children.each do |n|
        process n
      end
    ensure
      @parent_symbol = old_parent
    end
  end
end

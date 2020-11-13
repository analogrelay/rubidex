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
        symbol = define(node.children[0], location, :definition)
        process_children symbol, node.children.drop(1)
    end

    def on_class(node)
        location = node.location.keyword.join(node.location.name)
        symbol = define(node.children[0], location, :definition)

        define(node.children[1], location, :reference) unless node.children[1].nil?

        process_children symbol, node.children.drop(2)
    end

    def on_const(node)
        # Ignore consts for now
    end

    def handler_missing(node)
        @logger.debug "No handler for #{node.type} node."
    end

    private

    def define(node, location, type)
        raise ArgumentError, "must be provided a const node!" if node.nil? || node.type != :const

        parent = if node.children[0].nil?
            @parent_symbol
        else
            define(node.children[0], location, :reference) unless node.children[0].nil?
        end

        defn = Rubidex::Reference::new(@path, location, type)
        sym = @index.define_symbol(node.children[1], parent, defn)
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
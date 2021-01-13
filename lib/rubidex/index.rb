require 'parser/current'

class Rubidex::Index
    attr_reader :symbols

    def initialize(logger)
        @symbols = []
        @logger = logger
    end

    def define_symbol(name, parent, type, reference)
        symbol = @symbols.find { |s| s.parent == parent && s.name == name }
        if symbol.nil?
            id = @symbols.count + 1
            symbol = Rubidex::Symbol::new(id, name, parent, type)
            @symbols << symbol
        end
        symbol.add_reference(reference)
        symbol
    end

    def index_file(path)
        source = File.read(path)
        ast = Parser::CurrentRuby.parse(source)
        indexer = Rubidex::Indexer::new(self, path, logger: @logger)
        indexer.process(ast)
    end
end

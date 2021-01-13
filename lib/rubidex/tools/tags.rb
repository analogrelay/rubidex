require 'optparse'
require 'logger'

module Rubidex::Tools
  class Tags
    def self.execute(args)
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: rubidex-tags [options] [directories...]"

        opts.on("-F", "--fail-on-error", "Immediately exit with error details when a file cannot be processed") do |v|
          options[:fail_on_error] = v
        end

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end
      end
      parser.parse!(args, into: options)

      Tags::new(args, options).run()
    end

    def initialize(paths, options)
      @paths = paths
      @options = options
    end

    def run
      logger = Logger.new(STDOUT)

      logger.level = if @options[:verbose]
                       Logger::DEBUG
                     else
                       Logger::INFO
                     end

      index = Rubidex::Index::new(logger)

      each_file(@paths, nil) do |path|
        next unless path.end_with? ".rb"
        logger.info "Processing #{path}"
        begin
          index.index_file(path)
        rescue => boom
          raise if @options[:fail_on_error]
          logger.warn("Error processing #{path}: #{boom}")
        end
      end

      index.symbols.each do |sym|
        puts "* #{sym.type} symbol #{sym.ident}."
        sym.references.each do |ref|
          puts "  * #{ref}"
        end
      end
    end

    def each_file(paths, parent, &block)
      paths.each do |path|
        next if path == "." || path == ".."
        path = File.join(parent, path) unless parent.nil?

        if Dir.exists? path
          each_file(Dir.entries(path), path, &block)
        else
          block.call(path)
        end
      end
    end
  end
end

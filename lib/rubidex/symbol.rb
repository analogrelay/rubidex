module Rubidex
  class Symbol
    KNOWN_TYPES = [:class, :module, :call, :const].freeze

    attr_reader :id, :name, :parent, :type, :references

    def initialize(id, name, parent, type)
      raise ArgumentError, "Unknown symbol type #{type}" unless KNOWN_TYPES.include? type

      @id = id
      @name = name
      @parent = parent
      @type = type
      @references = Set::new
    end

    def full_name
      if parent.nil?
        name.to_s
      else
        separator =
          case @type
          when :module, :class
            "::"
          else
            "/"
          end
        "#{parent.full_name}#{separator}#{name}"
      end
    end

    def ident
      "#{full_name}@#{id}"
    end

    def add_reference(refs)
      @references << refs
    end
  end

  class Reference
    KNOWN_TYPES = [:definition, :reference].freeze

    attr_reader :path, :location, :type
    def initialize(path, location, type)
      raise ArgumentError, "Unknown reference type #{type}" unless KNOWN_TYPES.include? type

      @path = path
      @location = location
      @type = type
    end

    def search_string
      "^#{location.source_line}$"
    end

    def to_s
      "#{type} #{@path}@#{@location.begin.line}:#{@location.begin.column} /#{search_string}/"
    end

    def ==(other)
      other.instance_of?(Reference) &&
        other.type == type &&
        other.path == path &&
        other.location == location
    end
  end
end

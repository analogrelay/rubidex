module Rubidex
    class Symbol
        attr_reader :id, :name, :parent, :references

        def initialize(id, name, parent)
            @id = id
            @name = name
            @parent = parent
            @references = Set::new
        end

        def full_name
            if parent.nil?
                name.to_s
            else
                "#{parent.full_name}::#{name}"
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
        attr_reader :path, :location, :type
        def initialize(path, location, type)
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
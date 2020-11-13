require_relative 'lib/rubidex/version'

Gem::Specification.new do |spec|
  spec.name          = "rubidex"
  spec.version       = Rubidex::VERSION
  spec.authors       = ["Andrew Stanton-Nurse"]
  spec.email         = ["andrew@stanton-nurse.com"]

  spec.summary       = %q{A Ruby symbol indexing tool}
  spec.description   = %q{Maintains an index of Ruby symbols in a project}
  spec.homepage      = "https://github.com/anurse/rubidex"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/anurse/rubidex"
  spec.metadata["changelog_uri"] = "https://github.com/anurse/rubidex"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "parser", "~> 2.7"
end

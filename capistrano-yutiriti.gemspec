# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "capistrano-yutiriti"
  spec.version       = "0.0.1"
  spec.authors       = ["Martin Andert"]
  spec.email         = ["mandert@gmail.com"]

  spec.summary       = %q{capistrano-yutiriti}
  spec.description   = %q{capistrano-yutiriti}
  spec.homepage      = "https://github.com/martinandert/capistrano-yutiriti"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  gem.add_dependency "capistrano", "~> 3.4"
end

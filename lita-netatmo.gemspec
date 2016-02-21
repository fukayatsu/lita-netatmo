Gem::Specification.new do |spec|
  spec.name          = 'lita-netatmo'
  spec.version       = '0.1.1'
  spec.authors       = ['fukayatsu']
  spec.email         = ['fukayatsu@gmail.com']
  spec.description   = 'A Lita handler for fetching sensor data from netatmo.'
  spec.summary       = 'A Lita handler for fetching sensor data from netatmo.'
  spec.homepage      = 'https://github.com/fukayatsu/lita-netatmo'
  spec.license       = 'MIT'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '>= 4.2'
  spec.add_runtime_dependency 'oauth2'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'coveralls'
end

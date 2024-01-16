#encoding: utf-8

Gem::Specification.new do |gem|
  gem.name        = 'qat-web-video'
  gem.version     = '9.0.0'
  gem.summary     = %q{QAT-Web-Video is a screen recorder for Web testing evidences}
  gem.description = <<-DESC
  QAT-Web-Video is a screen recorder for Web testing evidences, with support for various browsers and webdrivers.
  DESC
  gem.email    = 'qatoolkit@readinessit.com'
  gem.homepage = 'https://gitlab.readinessit.com/qa-toolkit/qat-web-video'

  gem.authors = ['QAT']
  gem.license = 'Nonstandard'

  gem.files = Dir.glob('{lib}/**/*')

  gem.required_ruby_version = '~> 3.2.2'

  # Development dependencies
  gem.add_development_dependency 'headless', '~> 2.3.1'
  gem.add_development_dependency 'httparty', '~> 0.21.0'
  gem.add_development_dependency 'qat-devel', '~> 9.0.0'
  gem.add_development_dependency 'qat-cucumber', '~> 9.0.2'
  gem.add_development_dependency 'selenium-webdriver', '~> 4.12.0'
  gem.add_development_dependency 'sinatra', '~> 3.1.0'
  gem.add_development_dependency 'syntax', '~> 1.2.2'
  gem.add_development_dependency 'webrick', '~> 1.8.1'

  # GEM dependencies
  gem.add_dependency 'qat-web', '~> 9.0.3'

end

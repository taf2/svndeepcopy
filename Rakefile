require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'tools/rakehelp'

setup_tests
setup_rdoc ['README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc', 'ext/esi/esi.c']

desc "test"
task :default => [:test]

name="svndeepcopy"
version="0.0.1"

setup_gem(name, version) do |spec|
  spec.summary = "Deep copy svn paths"
  spec.description = "Deep copy svn paths following all svn:externals"
  spec.test_files = Dir.glob('test/test_*.rb')
  spec.author="Todd A. Fisher"
  spec.executables=['mongrel_esi']
  spec.files += %w(LICENSE README Rakefile setup.rb)

  spec.required_ruby_version = '>= 1.8.4'

  if RUBY_PLATFORM =~ /mswin/
    spec.files += ['lib/esi.so']
    spec.extensions.clear
    spec.platform = Gem::Platform::WIN32
  else
    spec.add_dependency('daemons', '>= 1.0.3')
    spec.add_dependency('fastthread', '>= 0.6.2')
  end
  
  spec.add_dependency('hpricot', '>= 0.6')
  spec.add_dependency('memcache-client', '>= 1.5.0')
  spec.add_dependency('gem_plugin', '>= 0.2.2')
  spec.add_dependency('cgi_multipart_eof_fix', '>= 1.0.0')
end

task :install do
  sub_project("gem_plugin", :install)
  sub_project("fastthread", :install)
  sh %{rake package}
  sh %{gem install pkg/mongrel-esi-#{version}}
  if RUBY_PLATFORM =~ /mswin/
    sub_project("mongrel_service", :install)
  end
end

task :uninstall => [:clean] do
  sh %{gem uninstall mongrel-esi}
  sub_project("gem_plugin", :uninstall)
  sub_project("fastthread", :uninstall)
  if RUBY_PLATFORM =~ /mswin/
    sub_project("mongrel_service", :install)
  end
end


task :gem_source do
  mkdir_p "pkg/gems"
 
  FileList["**/*.gem"].each { |gem| mv gem, "pkg/gems" }
  FileList["pkg/*.tgz"].each {|tgz| rm tgz }
  rm_rf "pkg/#{name}-#{version}"

  sh %{ index_gem_repository.rb -d pkg }
  # TODO: setup something like this
  #sh %{ scp -r ChangeLog pkg/* rubyforge.org:/var/www/gforge-projects/mongrel/releases/ }
end

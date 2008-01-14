# Rakefile for rgte -*- ruby -*-

# Copyright 2008 Scott Barron (scott@elitists.net)
# All rights reserved

# This file may be distributed under an MIT style license.  See
# MIT-LICENSE for details.

begin
  require 'rubygems'
  require 'rake/gempackagetask'
  require 'spec/rake/spectask'
rescue Exception
  nil
end

if `ruby -Ilib ./bin/rgte -v` =~ /rgte, version ([0-9.]+)$/
  CURRENT_VERSION = $1
else
  CURRENT_VERSION = '0.0.0'
end
$package_version = CURRENT_VERSION

PKG_FILES = FileList['[A-Z]*',
                     'bin/**/*',
                     'lib/**/*.rb'
                    ]

if !defined?(Gem)
  puts "Package target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|
    s.name = 'rgte'
    s.version = $package_version
    s.summary = 'Mail filtering tool'
    s.description = <<-EOF
rgte is a tool for filtering incoming email
EOF

    s.files = PKG_FILES.to_a

    s.require_path = 'lib'

    s.bindir = 'bin'

    s.executables = ['rgte']
    s.default_executable = 'rgte'

    s.has_rdoc = true

    s.author = 'Scott Barron'
    s.email = 'scott@elitists.net'
    s.homepage = 'http://rubyi.st/rgte'
  end

  package_task = Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
end

if !defined?(Spec)
  puts "spec and cruise targets requires RSpec"
else
  desc "Run all examples with RCov"
  Spec::Rake::SpecTask.new('cruise') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec']
  end
  
  desc "Run all examples"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = false
    t.spec_opts = ['-cfs']
  end
end


task :default => [:spec]

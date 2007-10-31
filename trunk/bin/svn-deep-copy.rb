#!/bin/env ruby

require "lib/svn/deep_copy"

svn_path_from = ARGV[0]
svn_path_to = ARGV[1]
if( svn_path_from.nil? or svn_path_to.nil? )
  STDERR.puts "Usage: #{ARGV[0]} svn_path_from svn_path_to"
  exit(1)
end

puts "Copying #{svn_path_from} to #{svn_path_to}"

svn_copy = SVN::DeepCopy.new
svn_copy.copy( svn_path_from, svn_path_to )


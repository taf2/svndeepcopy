# add lib into the load path
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'test/unit'
require 'rubygems'
require 'mocha'
require 'svn/deep_copy'


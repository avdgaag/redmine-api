$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'coverage'
Coverage.start
require 'redmine'
require 'minitest/autorun'
result = Coverage.result.values.flatten.compact
printf "Code coverage: %.2f%\n", result.inject(:+) / result.count.to_f * 100

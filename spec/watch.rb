require "rubygems"
require "bundler/setup"

# A simple alternative to autotest that isnt as painful
puts ">> Watching spec folder for changes..."

options = {
  :options => "--require '#{File.dirname(__FILE__)}/spec_helper' --format nested --color",
  :binary => "rspec"
}

watch("lib/(.*)\.rb") do
  puts %x[ clear ]
  
  opts   = options[:options]
  binary = options[:binary]
  files  = []

  %w{ lib }.each do |dir|
    ["spec/#{dir}/*/*.rb", "spec/#{dir}/*.rb"].each do |glob|
      Dir.glob(glob).each { |f| files << f }
    end
  end
  
  puts "Found:"
  files.each { |f| puts "+ #{f}" }
  puts ""
  command = "#{binary} #{files.collect! { |f| File.expand_path(f) }.join(" ")} #{opts}"

  system(command)
  
end

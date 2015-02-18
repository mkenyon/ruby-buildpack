require 'aws-sdk'
require 'open-uri'
require 'pry'

usage = <<USAGE
  Usage:
    ruby cp.rb pivotal-buildpacks lucid64/ruby https://raw.githubusercontent.com/cloudfoundry/ruby-buildpack/master/manifest.yml
USAGE

if ARGV.count < 3
  puts usage
  exit 1
end

bucket = ARGV[0]
path = ARGV[1]
manifest = ARGV[2]
manifest = YAML.load(open(manifest).read)
new_s3_bucket = AWS::S3.new.buckets[bucket]

manifest['dependencies'].each do |dependency|
  file_name = dependency['uri'].split('/').last

  `wget -O #{file_name} #{dependency['uri']}`
  next unless $?.to_i.zero?
  new_s3_bucket.objects["#{path}/#{file_name}"].write(file: file_name)
  File.delete(file_name)
end

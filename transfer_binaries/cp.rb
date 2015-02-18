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

ruby_dependencies = manifest['dependencies'].select { |dependency|
  dependency['name'] == 'ruby'
}

new_s3_bucket = AWS::S3.new.buckets[bucket]

ruby_dependencies.each do |dependency|
  tmp_name = "tmp-#{DateTime.now.strftime('%Q')}.tgz"
  `wget -O #{tmp_name} #{dependency['uri']}`
  new_s3_bucket.objects["#{path}/mri-#{dependency['version']}.tgz"].write(file: tmp_name)
  File.delete(tmp_name)
end

require "mini_portile"

class MiniPortile
 def extract_file(file, target)
    filename = File.basename(file)
    FileUtils.mkdir_p target

    message "Extracting #{filename} into #{target}... "
    result = `#{tar_exe} #{tar_compression_switch(filename)}xf "#{file}" --no-same-owner -C "#{target}" 2>&1`
    if $?.success?
      output "OK"
    else
      output "ERROR"
      output result
      raise "Failed to complete extract task"
    end
  end
end

version, patch = ARGV

recipe = MiniPortile.new("ruby", version)

source_uri ="http://cache.ruby-lang.org/pub/ruby/1.9/ruby-#{version}-p#{patch}.tar.gz"
recipe.files = [source_uri]

flags_to_remove = %w{
  --enable-static
  --disable-shared
}

recipe.configure_options.reject! { |opt| flags_to_remove.include? opt }

recipe.configure_options << "--enable-load-relative"
recipe.configure_options << "--disable-install-doc"
recipe.configure_options << "--disable-static"
recipe.configure_options << "--enable-shared"

puts "-----> Using config options: "
recipe.configure_options.each { |opt| puts "\t#{opt}" }
puts

recipe.cook

# TEST
puts "------> Running Tests"

actual_version = `cd #{recipe.path}; bin/ruby -v`
expected_version = "#{version}p#{patch}"

unless actual_version.include? expected_version
  puts "Ruby Version did not match"
  puts "Expected: #{actual_version}"
  puts "To Include: #{expected_version}"
  exit 1
end
print "."

actual_output = `cd #{recipe.path}; bin/ruby -e 'print "hello"'`
expected_output = 'hello'
if actual_output != expected_output
  puts "Ruby did not execute as expected"
  puts "Expected: #{actual_output}"
  puts "To Equal: #{expected_output}"
  exit 1
end

print "."

puts "\nTests passed!"

puts "Temp build in #{recipe.path}"

puts "------> Zipping it up "
`cd #{recipe.path}; tar cvzf #{ARGV[2]} *`


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

recipe = MiniPortile.new("ruby", ARGV[0].to_s)

recipe.files = [ARGV[1]]
recipe.configure_options << "--enable-load-relative"
recipe.configure_options << "--disable-install-doc"
recipe.configure_options << "--disable-static"
recipe.configure_options << "--enable-shared"

checkpoint = ".#{recipe.name}-#{recipe.version}.installed"

if File.exist?(checkpoint)
  puts "INFO: Already compiled"
else
  puts "-----> Using config options: "
  recipe.configure_options.each { |opt| puts "\t#{opt}" }
  puts

  recipe.cook

  `touch ${checkpoint}`
end

puts "Temp build in #{recipe.path}"

puts "------> Zipping it up "
`cd #{recipe.path}; tar cvzf #{ARGV[2]} *`


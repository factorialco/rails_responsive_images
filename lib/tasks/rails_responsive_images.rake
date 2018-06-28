require "rails_responsive_images"
require "byebug"

desc "Rails responsive images builds different sized versions from your images inside of the asset folder"
task rails_responsive_images: [ 'rails_responsive_images:check_requirements', 'rails_responsive_images:resize' ]

namespace :rails_responsive_images do

  desc "Check for required programms"
  task :check_requirements do
    RakeFileUtils.verbose(false)
    tools = %w[convert] # imagemagick
    puts "\nResize images with the following tools:"
    tools.delete_if { |tool| sh('which', tool) rescue false }
    raise "The following tools must be installed and accessible from the execution path: #{ tools.join(', ') }\n\n" if tools.size > 0
  end

  task resize: :environment do

    RakeFileUtils.verbose(false)
    start_time = Time.now

    # file_list = ::FileList.new(Rails.root.join('app', 'assets', 'images/**/*.{gif,jpeg,jpg,png}').to_s) do |f|
    #   f.exclude(/(responsive_images_)\d+/)
    # end

    file_list = Rails.application
      .precompiled_assets
      .select { |file| file =~ /\.(?:jpeg|jpg|png)$/ }
      .reject { |file| file =~ /responsive_images_/ }

    byebug

    puts "\nResize #{ file_list.size } image files."

    RailsResponsiveImages.configuration.image_sizes.each do |size|
      file_list.to_a.each do |filepath|
        resolved_filepath = Rails.application.assets[filepath].pathname.to_s

        original_dir = File.dirname(resolved_filepath)
        original_file = File.basename(resolved_filepath, ".*")
        original_ext = File.extname(resolved_filepath)

        responsive_filepath = Rails.root.join(original_dir, "#{original_file}_responsive_images_#{size}#{original_ext}").to_s

        RailsResponsiveImages::Image.instance.generate_responsive_image!(resolved_filepath, size, responsive_filepath)
      end
    end

    minutes, seconds = (Time.now - start_time).divmod 60
    puts "\nTotal run time: #{minutes}m #{seconds.round}s\n"
  end
end

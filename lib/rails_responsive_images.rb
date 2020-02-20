require 'action_view'
require 'rails_responsive_images/version'
require 'rails_responsive_images/configuration'
require 'rails_responsive_images/engine'

module RailsResponsiveImages
  def self.configuration
    @configuration ||= RailsResponsiveImages::Configuration.new
  end

  def self.configuration=(new_configuration)
    @configuration = new_configuration
  end

  def self.configure
    yield configuration if block_given?
  end

  def self.reset
    @configuration = nil
  end
end

ActionView::Helpers::AssetTagHelper.module_eval do
  def image_tag_with_responsiveness(source, options = {})
    options = options.symbolize_keys
    check_for_image_tag_errors(options)
    skip_pipeline = options.delete(:skip_pipeline)

    debug = Rails.application.config.assets.debug

    if debug && !RailsResponsiveImages.configuration.images.include?(source)
      raise "Image '#{source}' is not a responsive image. Review RailsResponsiveImages the configuration"
    end

    if debug
      RailsResponsiveImages.configuration.image_sizes.each do |size|
        resolved_filepath = Rails.application.assets[source].pathname.to_s

        original_dir = File.dirname(resolved_filepath)
        original_file = File.basename(resolved_filepath, ".*")
        original_ext = File.extname(resolved_filepath)

        responsive_filepath = Rails.root.join(original_dir, "#{original_file}_responsive_images_#{size}#{original_ext}").to_s

        unless File.exist?(responsive_filepath)
          RailsResponsiveImages::Image.instance.generate_responsive_image!(resolved_filepath, size, responsive_filepath)
        end
      end
    end

    options[:src] = resolve_image_source(source, skip_pipeline)

    original_dir = File.dirname(source)
    original_file = File.basename(source, ".*")
    original_ext = File.extname(source)

    options[:srcset] = RailsResponsiveImages.configuration.image_sizes.map do |size|
      src_path = path_to_image("#{original_dir}/#{original_file}_responsive_images_#{size}#{original_ext}", skip_pipeline: skip_pipeline)
      "#{src_path} #{size}w"
    end.join(", ")

    options[:width], options[:height] = extract_dimensions(options.delete(:size)) if options[:size]
    tag("img", options)
  end
end

module RailsResponsiveImages
  # Stores runtime configuration information.
  #
  # Example settings
  #   RailsResponsiveImages.configure do |c|
  #     c.image_sizes  = [767, 991, 1999]
  #     c.images = [
  #       'public/team/john.jpg',
  #       'public/team/charles.jpg'
  #     ]
  #   end
  class Configuration

    # The image_sizes to put into the picture source src attribute
    def image_sizes
      @image_sizes
    end

    def image_sizes=(new_sizes)
      @image_sizes = new_sizes
    end

    def images
      @images
    end

    def images=(items)
      @images = items
    end

    # Set default settings
    def initialize
      @image_sizes = [360, 576, 768, 992, 1200, 1600]
      @images = []
    end
  end
end

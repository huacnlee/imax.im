EasyCaptcha.setup do |config|
  # Cache
  config.cache          = true
  # Cache temp dir from Rails.root
  config.cache_temp_dir = Rails.root + 'tmp' + 'captchas'
  # Cache size
  config.cache_size     = 20
  # Cache expire
  config.cache_expire   = 10.seconds

  # Chars
  config.chars          = %w(2 3 4 5 8 A B C D E F G H J K L M N Q R S T U V W X Y Z)

  # Length
  config.length         = 4

  # Image
  config.image_height   = 28
  config.image_width    = 75

  # configure generator
  config.generator :default do |generator|

    # Font
    generator.font_size              = 18
    generator.font_fill_color        = "#FFFFFF"
    generator.font_stroke_color      = '#222222'
    generator.font_stroke            = 2
    # generator.font_family            = File.expand_path('../../resources/afont.ttf', __FILE__)

    generator.image_background_color = "#FFFFFF"

    # Wave
    # generator.wave                   = true
    # generator.wave_length            = (60..100)
    # generator.wave_amplitude         = (3..5)

    # Sketch
    generator.sketch                 = true
    generator.sketch_radius          = 0
    generator.sketch_sigma           = 0.5

    # Implode
    # generator.implode                = 0.3

    # Blur
    generator.blur                   = false
    # generator.blur_radius            = 0.5
    # generator.blur_sigma             = 0.2
  end
end
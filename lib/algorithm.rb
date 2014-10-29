require 'RMagick'

class Algorithm
  HI_RESOLUTION = 10000
  MED_RESOLUTION = 5000
  LO_RESOLUTION = 2500
  POOR_RESOLUTION = 1250
  GRID_NUMBER = 10

  def initialize file
    @im = ImageList.new file
  end

  def calculate_photo_quality
    grid_sampling
  end

  private
  def grid_sampling

    height, width = @im.rows, @im.columns
    y_step = (height / GRID_NUMBER).round
    x_step = (width / GRID_NUMBER).round
    samples = []
    (0..width-x_step).step(x_step) do |x|
      (0..height-y_step).step(y_step) do |y|
        crop_image = @im.crop(x,y,y_step, y_step)
        samples.push crop_image.total_colors
      end
    end
    (samples.inject{|sum,x| sum + Math.log(x) } / GRID_NUMBER).round + 1
  end

  def overlay_image
    combined_image = @im
    height, width = @im.rows * 2, @im.columns * 2
    scores = []
    background_colors = ['white', 'red', 'black', 'yellow']
    scores = background_colors.map { |bg|
      top_layer = Image.new(height, width) {self.background_color=bg}
      top_layer.alpha(Magick::ActivateAlphaChannel)
      top_layer.opacity = (1 - 0.8) * Magick::QuantumRange
      combined_image.alpha(Magick::ActivateAlphaChannel)
      combined_image = combined_image.composite(top_layer, Magick::NorthWestGravity, 0, 0, Magick::OverCompositeOp)
      stdev_diff_percentage combined_image, @im }.push
    sum = scores.inject{|sum,x| sum + x }
    puts sum / scores.count
  end

  def dpi_image
    dpi = @im.x_resolution * @im.y_resolution
    if dpi >= HI_RESOLUTION
      quality = rand(90..99)
    elsif dpi >= MED_RESOLUTION
      quality = rand(80..89)
    elsif dpi >= LO_RESOLUTION
      quality = rand(70..79)
    elsif dpi >= LO_RESOLUTION
      quality = rand(50..69)
    end
  end

  def normalized_image
    stdev_diff_percentage @im, @im.normalize
  end

  def sharpen_image
    stdev_diff_percentage @im, @im.sharpen
  end

  def equalize_image
    stdev_diff_percentage @im, @im.equalize
  end

  def stdev_diff_percentage original, modified
    original_stdev = original.channel_mean.last
    modified_stdev = modified.channel_mean.last

    diff = (modified_stdev - original_stdev).abs
    if modified_stdev > 0
      percentage = diff / modified_stdev
      ((1 - percentage) * 100).round
    else
      rand(1..10)
    end
  end
end
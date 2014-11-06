require "sanitize"
require "htmlentities"
require "yaml"

class Blinkbox::Onix2Processor::Processor
  def normalize_tags(array)
    array.collect do |tag|
      (SHORT_TAGS[tag.downcase] || tag).downcase
    end
  end

  def sanitize_html(html)
    Sanitize.clean(html, @@valid_html)
  end

  def product_failure(state, name, data = {})
    state[:product_failures].push(
      error_code: name,
      data: data
    )
  end

  def self.yaml_config(file)
    YAML.load(open(File.join(__dir__, "../../../../config/#{file}.yaml"))).freeze
  end

  SHORT_TAGS = yaml_config("short_codes")
end

class String
  def clever_decode!
    2.times do
      break unless self.match(/&(?:#?\d{2,3}|[a-z]+);/)
      self.replace(HTMLEntities.new.decode(self))
    end
    self
  end
end
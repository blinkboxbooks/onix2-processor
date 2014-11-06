require "sanitize"
require "htmlentities"

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

  SHORT_TAGS = YAML.load(open(File.join(__dir__, "../../../../config/short_codes.yaml"))).freeze
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
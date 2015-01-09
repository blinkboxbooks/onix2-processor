# require 'linguistics'
# Linguistics.use(:en)

class String
  # Will turn a string into a number, even if it's a word-number
  #
  #     integerize("1") # => 1
  #     integerize("one") # => 1
  #     integerize("forty two") # => 42
  #     integerize("monkey") # => nil
  #
  def integerize
    return nil
    # return nil if self.empty?
    # return self.to_i if self.to_i.to_s == self

    # parts = self.downcase.split(/[ -]/)

    # case parts.length
    # when 1
    #   n = (Linguistics::EN::Numbers::UNITS + Linguistics::EN::Numbers::TEENS).index(parts[0])
    #   return n unless n.nil?

    #   return Linguistics::EN::Numbers::TENS.index(parts[0]) * 10 rescue nil
    # when 2
    #   n = Linguistics::EN::Numbers::TENS.index(parts[0]) * 10 rescue nil
    #   return nil if n.nil?

    #   return n + Linguistics::EN::Numbers::UNITS.index(parts[1])
    # end

    # nil
  end
end

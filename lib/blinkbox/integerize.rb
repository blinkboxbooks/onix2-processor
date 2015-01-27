class String
  # Will turn a string into a number, even if it's a word-number
  #
  #     integerize("1") # => 1
  #     integerize("one") # => 1
  #     integerize("forty two") # => 42
  #     integerize("monkey") # => nil
  #
  # TODO: Due to issues with the integerize gem and character encodings I've removed this code,
  # check the git history and use the code there to fix this...
  def integerize
    return self.to_i if self.to_i.to_s == self
    return nil
  end
end

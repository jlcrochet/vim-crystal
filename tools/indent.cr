WORDS = %w(=end =else =elsif 0=when 0=in 0=rescue 0=ensure)
CHARACTERS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_?!:"

words = [] of String

WORDS.each do |word|
  words << word

  CHARACTERS.each_char do |char|
    words << word + char
  end
end

puts words.join ','

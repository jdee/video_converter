class String
  # Get an obfuscated copy of the string.
  # @see #obfuscate!
  #
  # @return [String] An obfuscated copy of self
  def obfuscate
    string = clone
    string.obfuscate!
    string
  end

  # Obfuscates the receiver by first replacing all instances
  # of the HOME environment variable with '~' and then all instances of
  # USER with '${USER}'.
  # @see #obfuscate
  #
  # @return nil
  def obfuscate!
    gsub!(/#{Regexp.quote ENV['HOME']}/, '~')
    gsub!(/#{Regexp.quote ENV['USER']}/, '${USER}')
    nil
  end

  # Determine whether the path represented by the receiver is
  # an MP4 video, whether or not it exists.
  #
  # @return true If the file extension is .mp4, false Otherwise
  def is_mp4?
    video_type == :mp4
  end

  # Returns the video type for the path represented by the
  # receiver, whether or not the file exists. This is just
  # the file extension as a lowercase symbol, e.g. :mp4, :mov,
  # :avi, etc.
  #
  # @return [Symbol] The file extension as a lowercase symbol
  def video_type
    # Just file extension as a symbol
    File.extname(self).sub(/^\./, '').downcase.to_sym
  end
end

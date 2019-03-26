describe String do
  it 'obfuscates the home directory' do
    home = ENV['HOME']
    input = "#{home}/abc"
    input.obfuscate!
    expect(input).not_to match(/#{Regexp.quote home}/)
  end
end

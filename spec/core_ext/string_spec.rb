describe String do
  before :all do
    ENV['HOME'] = '/Users/me' if ENV['HOME'].nil?
  end

  it 'obfuscates the home directory' do
    home = ENV['HOME']
    input = "#{home}/abc"
    input.obfuscate!
    expect(input).not_to match(/#{Regexp.quote home}/)
  end
end

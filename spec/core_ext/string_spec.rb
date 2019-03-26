describe String do
  before :all do
    ENV['HOME'] ||= '/Users/me'
  end

  it 'obfuscates the home directory' do
    home = ENV['HOME']
    input = "#{home}/abc"
    input.obfuscate!
    expect(input).to eq '~/abc'
  end
end

describe String do
  context 'Obfuscation' do
    before :all do
      ENV['USER'] ||= 'me'
      ENV['HOME'] ||= "/Users/#{ENV['USER']}"
    end

    it 'obfuscates the home directory' do
      home = ENV['HOME']
      input = "#{home}/abc"
      input.obfuscate!
      expect(input).to eq '~/abc'
    end

    it 'obfuscates the username' do
      user = ENV['USER']
      input = "/a/b/c/#{user}"
      input.obfuscate!
      expect(input).to eq '/a/b/c/$USER'
    end

    it 'obfuscates the home directory first' do
      home = ENV['HOME']
      user = ENV['USER']
      input = "#{home}/github/#{user}/project"
      input.obfuscate!
      expect(input).to eq '~/github/$USER/project'
    end

    it '#obfuscate returns an obfuscated copy' do
      home = ENV['HOME']
      user = ENV['USER']
      input = "#{home}/github/#{user}/project"
      output = input.obfuscate
      expect(output).to eq '~/github/$USER/project'
      expect(input).to eq "#{home}/github/#{user}/project"
    end
  end

  context 'Video type determination' do
    let(:lower_mp4) { 'file.mp4' }
    let(:upper_mp4) { 'file.MP4' }
    let(:lower_mov) { 'file.mov' }
    let(:upper_mov) { 'file.MOV' }

    it '#video_type returns the extension as a lowercase symbol' do
      expect(lower_mp4.video_type).to eq :mp4
      expect(upper_mp4.video_type).to eq :mp4
      expect(lower_mov.video_type).to eq :mov
      expect(upper_mov.video_type).to eq :mov
    end

    it '#is_mp4? returns true for :mp4 paths (false otherwise)' do
      expect(lower_mp4.is_mp4?).to be true
      expect(upper_mp4.is_mp4?).to be true
      expect(lower_mov.is_mp4?).to be false
      expect(upper_mov.is_mp4?).to be false
    end
  end
end

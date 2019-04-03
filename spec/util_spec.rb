describe VideoConverter::Util do
  include VideoConverter::Util

  describe '#boolean_env_var?' do
    before :all do
      ENV['FOO_y'] = 'y'
      ENV['FOO_Y'] = 'Y'
      ENV['FOO_t'] = 't'
      ENV['FOO_T'] = 'T'
      ENV['FOO_true'] = 'true'
      ENV['FOO_YES'] = 'YES'
      ENV['FOO_NO'] = 'NO'
    end

    after :all do
      ENV['FOO_y'] = nil
      ENV['FOO_Y'] = nil
      ENV['FOO_t'] = nil
      ENV['FOO_T'] = nil
      ENV['FOO_true'] = nil
      ENV['FOO_YES'] = nil
      ENV['FOO_NO'] = nil
    end

    it 'Returns the default value if the variable is not set' do
      expect(boolean_env_var?(:FOO, default_value: false)).to be false
      expect(boolean_env_var?(:FOO, default_value: true)).to be true
    end

    it 'Returns true if the value begins with y or t (case-insensitive)' do
      expect(boolean_env_var?(:FOO_y)).to be true
      expect(boolean_env_var?(:FOO_Y)).to be true
      expect(boolean_env_var?(:FOO_t)).to be true
      expect(boolean_env_var?(:FOO_t)).to be true
      expect(boolean_env_var?(:FOO_true)).to be true
      expect(boolean_env_var?(:FOO_YES)).to be true
    end

    it 'Returns false unless the value begins with y or t (case-insensitive)' do
      expect(boolean_env_var?(:FOO_NO)).to be false
    end
  end
end

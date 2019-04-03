require 'colored'
require_relative File.join('core_ext', 'io')

module VideoConverter
  # Module with utility methods
  module Util
    # List of commands whose package names differ from the command.
    EXCEPTIONS = { mp4info: :mp4v2 }

    # Determine if the brew command is available.
    #
    # @return true if found, false otherwise
    def have_brew?
      have_command? :brew
    end

    # Determine if a specific command is available.
    #
    # @param command [#to_s] A command to check for
    # @return true if found, false otherwise
    def have_command?(command)
      # May be shell-dependent, OS-dependent
      # Kernel#system does not raise Errno::ENOENT when running under the Bundler
      !`which #{command}`.empty?
    end

    # Install a package using homebrew.
    #
    # @param packages [#to_s, Array<#to_s>] Packages to be installed via homebrew
    # @param log [IO] Optional log to write to
    # @return true if successful, false otherwise
    def install(packages, log: STDOUT)
      packages = [packages] unless packages.kind_of?(Array)
      command = ['brew', 'install', *packages.map(&:to_s)]
      log.log_command command
      system(*command, %i[err out] => log)
    end

    # Get the package for a required command.
    #
    # @param command [#to_sym] A required command
    # @return [Symbol] The package associated with the command
    def package_for_command(command)
      command = command.to_sym
      exception = EXCEPTIONS[command]
      exception.nil? ? command : exception
    end

    # Check for commands.
    #
    # @param commands [Array<#to_s>, #to_s] A list of commands to check for
    # @param log [IO] Optional log to write to
    # @return true if all required commands successfully installed, false otherwise
    def check_commands(commands, log: STDOUT)
      commands = [commands] unless commands.kind_of?(Array)
      to_install = commands.reject { |c| have_command? c }.map { |c| package_for_command c }
      return true if to_install.empty?

      unless have_brew?
        log.log "brew command not found. Cannot install packages: #{to_install.join ', '}.".yellow
        log.log "PATH=#{ENV['PATH']}".yellow
        return false
      end

      install to_install, log: log
    end

    # Return a Boolean value associated with an environment variable.
    #
    # @param var [#to_s] The name of an environment variable
    # @param default_value [true, false] Returned if the environment variable is not set
    # @return true if the value of the environment variable begins with y or t (case-insensitive)
    def boolean_env_var?(var, default_value: false)
      value = ENV[var.to_s]
      return default_value if value.nil?

      /^(y|t)/i.match? value
    end
  end
end

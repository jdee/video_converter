require 'colored'
require_relative File.join('core_ext', 'io')

module VideoConverter
  # Base class for exceptions from this gem
  class VideoConverterException < RuntimeError
  end

  # Exception raised by Converter#convert_file when conversion fails
  class ExecutionError < VideoConverterException
  end

  # Module with utility methods
  module Util
    # Execute the specified command. If output is non-nil, generate a log
    # at that location. Main log (open) is log.
    #
    # @param command Variadic command to be executed
    # @param output [String, Symbol, IO] Output for command (path, IO or a symbol such as :close)
    # @param log [IO, nil] Open IO for main log (nil to suppress logging command to main log)
    # @return nil
    # @raise ExecutionError If the command fails
    def execute(*command, output: STDOUT, log: STDOUT)
      log.log_command command unless log.nil?

      system(*command, %i[err out] => output)

      raise ExecutionError unless $?.success?

      nil
    end

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

    # Install packages using homebrew.
    #
    # @param packages [#to_s, Array<#to_s>] Packages to be installed via homebrew
    # @param log [IO] Optional log to write to
    # @return nil
    # @raise ExecutionError If installation fails
    def install(packages, log: STDOUT)
      packages = [packages] unless packages.kind_of?(Array)
      command = ['brew', 'install', *packages.map(&:to_s)]
      execute(*command, output: log, log: log)
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

      begin
        install to_install, log: log
        true
      rescue ExecutionError
        false
      end
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

    # Return a Float value associated with an environment variable.
    #
    # @param var [#to_s] The name of an environment variable
    # @param default_value [#to_f] Returned if the environment variable is not set
    # @return [Float] the numeric value of the environment variable or the default_value
    def float_env_var(var, default_value: 0)
      value = ENV[var.to_s]
      return default_value.to_f if value.nil?

      value.to_f
    end
  end
end

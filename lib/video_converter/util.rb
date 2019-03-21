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
      # Less shell-dependent way of checking than
      # !`which #{command}`.empty?
      # Assumes that running each command with no args produces no side
      # effects.
      system command.to_s
      true
    rescue Errno::ENOENT
      false
    end

    # Install a package using homebrew.
    #
    # @param package [#to_s] A package to be installed via homebrew
    # @param log [IO] Optional log to write to
    # @return true if successful, false otherwise
    def install(package, log: STDOUT)
      command = ['brew', 'install', package.to_s]
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
        return false
      end

      to_install.map do |package|
        install package, log: log
      end.all?
    end
  end
end

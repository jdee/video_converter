require 'shellwords'
require 'time'
require_relative 'string'

# Logging extensions to the IO class
class IO
  # Logs a message with obfuscation and a timestamp.
  # @see String#obfuscate!
  #
  # @param message [#to_s] A message to log. Will be converted to a String and obfuscated.
  # @return nil
  def log(message)
    puts "#{DateTime.now} #{message.to_s.obfuscate}"
  end

  # Logs a command to be executed by a call such as Kernel#system.
  # If the command parameter is an Array, it will be joined using
  # Array#shelljoin from shellwords. Otherwise it will be interpolated
  # in a String.
  #
  # @param command [Array, #to_s] A command to be logged
  # @return nil
  def log_command(command)
    string_to_log = (command.kind_of?(Array) ? command.shelljoin : command)
    log "$ #{string_to_log}".cyan.bold
    flush
    nil
  end
end

# Logs a message to STDOUT with obfuscation and a timestamp.
# @see String#obfuscate!
#
# @param message [#to_s] A message to log. Will be converted to a String and obfuscated.
# @return nil
def log(message)
  STDOUT.log message
end

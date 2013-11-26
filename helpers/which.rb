module Helper
  class Which
    #   which('ruby') #=> /usr/bin/ruby
    #
    # This code is adapted from the following post by mislav:
    #   http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    #
    # @param [String] cmd The command to search for in the PATH.
    # @return [String] The full path to the executable or `nil` if not found.
    def self.which(cmd)
      exts = ['']

      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = "#{path}#{File::SEPARATOR}#{cmd}#{ext}"
          return exe if File.executable? exe
        end
      end

      return nil
    end
  end
end

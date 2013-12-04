require_relative 'helpers/which'

class String
  def safe
    self.split(/&|\||\>|\</).shift.strip
  end
  def safe_name?
    return false if self.split(' ').size > 1
    true
  end
end

module Ezjail
  class Jail

    def self.create(jail, ip)
      error unless jail.to_s.safe_name?
      error unless execute(__method__.to_sym, jail, ip)[:success]
    end

    def self.delete(jail, stop=false, remove=false)
      error unless jail.to_s.safe_name?
      args = "#{jail} #{'-f' if stop} #{'-w' if remove}".strip!
      result = execute(__method__.to_sym, args)
      error unless result[:success]
      result[:success]
    end

    %w{ :start, :stop, :restart, :cryptostart }.each do |method_name|
      define_singleton_method(method_name) do |jail|
        error unless jail.to_s.safe_name?
        error unless execute(__method__.to_sym, jail)[:success]
      end
    end

    def self.list
      list = execute(__method__.to_sym)
      error unless list[:success]
      organize(list[:out])
    end

    private

    def self.error
      raise Error, "Execution of #{caller[0][/`.*'/][1..-2]} method failed."
    end

    def self.present?(name)
      result = false
      list.each_value do |jail|
        result = true if name.eql? jail[:name]
      end
      result
    end

    def self.execute(cmd, *args)
      ezjail_bin = Helper::Which.which('ezjail-admin')
      raise Error, "Can not find ezjail-admin binary." if ezjail_bin.nil?
      cmd = "#{ezjail_bin} #{cmd.to_s.safe} #{args.join(' ').safe if args.size != 0}".strip!
      output = `#{cmd}`
      {out: output.split("\n"), success: $?.success?}
    end

    def self.organize(jail_list)
      result = Hash.new
      jail_list.shift(2)
      jail_list.map! { |s| s.split(' ') }
      jail_list.each do |l|
        # If first field is ezjail flags move it to the end of array
        # From man EZJAIL-ADMIN(8) :
        # The first column is the status flag consisting of 2 or 3 letters. The
        # first letter is the type of jail:
        #   D     Directory tree based jail.
        #   I     File-based jail.
        #   E     Geli encrypted file-based jail.
        #   B     Bde encrypted file-based jail.
        #   Z     ZFS filesystem-based jail.
        #
        # The second letter is the status of the jail:
        #   R     The jail is running.
        #   A     The image of the jail is mounted, but the jail is not running.
        #   S     The jail is stopped.
        #
        # If present, the third letter, N, means that the jail is not automatically started.
        l.push(l.shift) if l[0] =~ /^[DIEBZ][RAS]N?$/

        tmp = l[1].split(/\/|\|/)
        network = {interface: "#{tmp.shift if tmp.size > 2}", mask: tmp.pop, ip: tmp.join}

        # Yeeah i know that this regexp ugly and not precise
        raise 'Invalid input format' unless /^([0-9]{1,3}.){3}[0-9]{1,3}$/ === network[:ip] and
                                            /^[0-9]{2}$/ === network[:mask] and
                                            /^([a-z0-9]*)?$/ === network[:interface]
        jail = {network: []}
        if l.size > 2
          jail[:network].push(network)
          jail[:name] = l[2]
          jail[:path] = l[3]
          jail[:status] = l[4]
          result[l[0]] = jail
        else
          result[l[0]][:network].push(network)
        end
      end
      result
    end
  end

  class Error < StandardError
  end
end
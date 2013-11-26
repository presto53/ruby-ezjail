require_relative 'helpers/which'

module Ezjail
  class Jail

    def self.create(name, ip)

    end

    def self.destroy(name)

    end

    def self.list
      list = execute(:list)
      raise EzjailError, "Execution of list command failed." unless list[:success]
      organize(list[:out])
    end

    private

    def self.present?(name)
      result = false
      list.each_value do |jail|
        result = true if name.eql? jail[:name]
      end
      result
    end

    def self.execute(cmd, *args)
      ezjail_bin = Helper::Which.which('ezjail-admin')
      raise EzjailError, "Can not find ezjail-admin binary." if ezjail_bin.nil?
      output = `#{ezjail_bin} #{cmd} #{args.join(' ')}`
      {out: output.split("\n"), success: $?.success?}
    end

    def organize(jail_list)
      result = Hash.new
      jail_list.shift(2).map! { |s| s.split(' ') }
      jail_list.each do |l|
        jail = {ip: []}

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
        if l[0] =~ /^[DIEBZ][RAS]N?$/
          l.push(l.shift)
        end

        tmp = l[1].split(/\/|\|/)
        network = {interface: "#{tmp.shift if tmp.size > 2}", mask: tmp.pop, address: tmp}

        if l.size > 2
          jail[:ip].unshift(network)
          jail[:name] = l[2]
          jail[:path] = l[3]
          jail[:status] = l[4]
          result[l[0]] = jail
        else
          result[l[0]][:ip].unshift(network)
        end
      end
      result
    end
  end

  class EzjailError < StandardError
  end
end
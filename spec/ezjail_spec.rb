require 'rspec'
require 'spec_helper'

describe 'Ezjail' do
  describe 'Jail'
  before(:each) do
    allow(Ezjail::Jail).to receive(:execute).and_return({:out => ['Stub'], :success=>true})
    allow(Ezjail::Jail).to receive(:execute).with(:list).and_return(
                               {:out=>['STA JID  IP              Hostname                       Root Directory',
                                       '--- ---- --------------- ------------------------------ ------------------------',
                                       'ZR  13   172.16.77.59/16   srv01.example.com          /jails/srv01.example.com',
                                       'ZR  1    192.168.77.7/24   example.com             /jails/example.com',
                                       '    1    vlan2|192.168.77.213/24',
                                       'ZR  7    172.16.77.31/16   srv09.example.com         /jails/srv09.example.com'], :success=>true
                               })
    @jails_hash = { '13' => {status: 'ZR',
                             name: 'srv01.example.com',
                             path: '/jails/srv01.example.com',
                             network: [{interface: '', ip: '172.16.77.59', mask: '16'}]},
                    '1' => {status: 'ZR',
                            name: 'example.com',
                            path: '/jails/example.com',
                            network: [{interface: '', ip: '192.168.77.7', mask: '24'},
                                      {interface: 'vlan2', ip: '192.168.77.213', mask: '24'}]},
                    '7' => {status: 'ZR',
                            name: 'srv09.example.com',
                            path: '/jails/srv09.example.com',
                            network: [{interface: '', ip: '172.16.77.31', mask: '16'}]}
    }
    @ezjail_bin = Helper::Which.which('ezjail-admin')
    @jail_name = 'glenda'
    @deleted_successful = {out: 'Delete successful', success: true}
    @delete_unsuccessful = {out: 'Delete unsuccessful', success: false}
  end

  context '.list' do
    it 'return hash of jails' do
      expect(Ezjail::Jail.list).to eq(@jails_hash)
    end
  end

  context '.delete' do
    it 'delete jail without parameters' do
      allow(Ezjail::Jail).to receive(:`).with("#{@ezjail_bin} delete #{@jail_name}").and_return @deleted_successful
      expect(Ezjail::Jail.delete(@jail_name)).to eq(true)
    end
    it 'delete jail with -w param' do
      allow(Ezjail::Jail).to receive(:`).with("#{@ezjail_bin} delete #{@jail_name} -w").and_return @deleted_successful
      expect(Ezjail::Jail.delete(@jail_name, remove=true)).to eq(true)
    end
    it 'delete jail with -f param' do
      allow(Ezjail::Jail).to receive(:`).with("#{@ezjail_bin} delete #{@jail_name} -f").and_return @deleted_successful
      expect(Ezjail::Jail.delete(@jail_name, stop=true)).to eq(true)
    end
    it 'delete jail with -f and -w params' do
      allow(Ezjail::Jail).to receive(:`).with("#{@ezjail_bin} delete #{@jail_name} -f -w").and_return @deleted_successful
      expect(Ezjail::Jail.delete(@jail_name, true, true)).to eq(true)
    end
    it 'fail with unsafe name' do
      allow(Ezjail::Jail).to receive(:`).and_return @deleted_successful
      expect {Ezjail::Jail.delete("#{@jail_name} -xxx")}.to raise_error(Ezjail::Error)
    end
  end
end
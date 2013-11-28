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
                               }
                           )
    @jails_hash = { 13 => {status: 'ZR',
                           name: 'srv01.example.com',
                           path: '/jails/srv01.example.com',
                           network: [{ip: '172.16.77.59',mask: '16'}]
    },
                    1 => {status: 'ZR',
                          name: 'srv01.example.com',
                          path: '/jails/srv01.example.com',
                          network: [{ip: '192.168.77.7',mask: '24'},{interface:'vlan2', ip: '192.168.77.213',mask: '24'}]
                    },
                    7 => {status: 'ZR',
                          name: 'srv01.example.com',
                          path: '/jails/srv01.example.com',
                          network: [{ip: '172.16.77.31',mask: '16'}]
                    }
    }
  end
  context '.list' do
    it 'return hash of jails' do
      expect(Ezjail::Jail.list).to eq(@jails_hash)
    end
  end

end
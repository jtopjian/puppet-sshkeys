require 'spec_helper'

describe 'sshkeys::create_ssh_key' do

  let(:facts) do
    {
      :fqdn         => 'example.com',
      :home_jdoe => '/home/jdoe',
    }
  end

  context "With default parameters" do
    let(:title) { 'jdoe' }

    it { should contain_file('/home/jdoe/.ssh').with(:owner => 'jdoe') }
    it { should contain_exec('ssh_keygen-jdoe').with(:command => "/usr/bin/ssh-keygen -t rsa -b 2048 -f '/home/jdoe/.ssh/id_rsa' -N '' -C 'jdoe@example.com'") }

  end

  context "With custom parameters" do

    let(:title) { 'jdoe' }

    let :params do
      {
        :ssh_keytype => 'dsa',
        :passphrase  => 'foobar',
      }
    end

    it do
      should contain_exec('ssh_keygen-jdoe').with({
        :command => "/usr/bin/ssh-keygen -t dsa -b 1024 -f '/home/jdoe/.ssh/id_dsa' -N 'foobar' -C 'jdoe@example.com'",
        :user    => 'jdoe',
        :creates => '/home/jdoe/.ssh/id_dsa',
      })
    end
  end

end

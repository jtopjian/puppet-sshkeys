require 'spec_helper'

describe 'sshkeys::create_key' do

  let(:facts) do
    {
      :fqdn => 'example.com',
    }
  end


  context "With default parameters" do
    let(:title) { 'jdoe' }

    it do
      should contain_sshkeys__create_ssh_directory('jdoe').with({
        :home         => '/home/jdoe',
        :require_user => false,
      })
    end

    it do
      should contain_file('/home/jdoe').with({
        :ensure => 'directory',
        :owner  => 'jdoe',
        :group  => 'jdoe',
        :mode   => '0750',
      })
    end

    it do
      should contain_exec('ssh_keygen-jdoe').with({
        :command => "/usr/bin/ssh-keygen -t rsa -f \"/home/jdoe/.ssh/id_rsa\" -N '' -C 'jdoe@example.com'",
        :user    => 'jdoe',
        :creates => '/home/jdoe/.ssh/id_rsa',
      })
    end
  end

  context "With custom parameters" do

    let(:title) { 'root' }

    let :params do
      {
        :home        => '/root',
        :ssh_keytype => 'dsa',
        :passphrase  => 'foobar',
      }
    end

    it do
      should contain_exec('ssh_keygen-root').with({
        :command => "/usr/bin/ssh-keygen -t dsa -f \"/root/.ssh/id_dsa\" -N 'foobar' -C 'root@example.com'",
        :user    => 'root',
        :creates => '/root/.ssh/id_dsa',
      })
    end
  end

end

require 'spec_helper'

describe 'sshkeys::create_ssh_directory' do

  context "with default parameters" do

    let(:title) { 'jdoe' }

    it do
      should contain_file('/home/jdoe/.ssh').with({
        :ensure => 'directory',
        :owner  => 'jdoe',
        :mode   => '0700',
      })
    end
  end

  context "with root as home" do
    let(:title) { 'root' }

    let :params do
      {
        :home => '/root',
      }
    end

    it do
      should contain_file('/root/.ssh').with({
        :ensure => 'directory',
        :owner  => 'root',
        :mode   => '0700',
      })
    end
  end
end

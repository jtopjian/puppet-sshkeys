require 'etc'

# First get a list of users via the homedir_users fact
#
# An example of this file looks like:
# $ cat /etc/facter/facts.d/homedir_users.yaml
# ---
# homedir_users:
#   - root
#   - jdoe
#
# Missing users will be skipped
#
# If this fact does not exist, all users in /etc/passwd
# will have their keys discovered.
#
users = {}
homedir_users = Facter.value(:homedir_users)
if homedir_users != nil and homedir_users.size > 0
  homedir_users.each do |u|
    begin
      pw = Etc.getpwnam(u)
      user = pw.name.gsub(/[^a-zA-Z0-9_]/, '')
      homedir = pw.dir
      key = false

      if File.exists?("#{homedir}/.ssh/id_rsa.pub")
        key = IO.read("#{homedir}/.ssh/id_rsa.pub")
      elsif File.exists?("#{homedir}/.ssh/id_dsa.pub")
        key = IO.read("#{homedir}/.ssh/id_dsa.pub")
      end
      if key
        users[user] = key
      end
    rescue
      next
    end
  end
else
  Etc.passwd do |pw|
    user = pw.name.gsub(/[^a-zA-Z0-9_]/, '')
    homedir = pw.dir
    key = false

    if File.exists?("#{homedir}/.ssh/id_rsa.pub")
      key = IO.read("#{homedir}/.ssh/id_rsa.pub")
    elsif File.exists?("#{homedir}/.ssh/id_dsa.pub")
      key = IO.read("#{homedir}/.ssh/id_dsa.pub")
    end

    if key
      users[user] = key
    end
  end
end

users.each do |user_name, user_key|
  Facter.add("sshpubkey_#{user_name}") do
    setcode do
      user_key
    end
  end
end

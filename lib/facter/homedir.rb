# reference: http://serverfault.com/questions/420749/puppet-get-users-home-directory
require 'etc'

Etc.passwd { |user|

   Facter.add("home_#{user.name}") do
      setcode do
         user.dir
      end
   end

}

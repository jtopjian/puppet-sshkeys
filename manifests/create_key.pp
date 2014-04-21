# == Defined Type: sshkeys::create_key
#
#   Creates an SSH key for a user
#
# === Parameters
#
#   [*home*]
#     The homedir of the user.
#
#   [*require_user*]
#     Require a User[username] resource.
#
#   [*manage_home*]
#     manage_home attribute of the User resource.
#
#   [*create_ssh_dir*]
#     Whether to create /home/user/.ssh.
#
#   [*ssh_keytype*]
#     Either rsa or dsa.
#
#   [*passphrase*]
#     Optional passphrase to set on the key.
#
define sshkeys::create_key (
  $home           = undef,
  $require_user   = false,
  $manage_home    = true,
  $create_ssh_dir = true,
  $ssh_keytype    = 'rsa',
  $passphrase     = ''
) {

  if $home {
    $home_real = $home
  } else {
    $home_real = "/home/${name}"
  }

  if $create_ssh_dir {
    sshkeys::create_ssh_directory { $name:
      home         => $home_real,
      require_user => $require_user,
    }
    $require1 = [File["${home_real}/.ssh"]]
  } else {
    $require1 = []
  }

  if $require_user {
    $require2 = concat($require1, [User[$name]])
  } else {
    $require2 = $require1
  }

  if $manage_home {
    file { $home_real:
      ensure => directory,
      owner  => $name,
      group  => $name,
      mode   => '0750',
    }
    $require3 = concat($require2, [File[$home_real]])
  } else {
    $require3 = $require2
  }

  exec { "ssh_keygen-${name}":
    command => "/usr/bin/ssh-keygen -t ${ssh_keytype} -f \"${home_real}/.ssh/id_${ssh_keytype}\" -N '${passphrase}' -C '${name}@${::fqdn}'",
    user    => $name,
    creates => "${home_real}/.ssh/id_${ssh_keytype}",
    require => $require3,
  }
}

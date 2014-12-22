# == Defined Type: sshkeys::create_key
#
#   Creates an SSH key for a user
#
# === Parameters
#
#   [*owner*]
#     The owner of the homedir.
#
#   [*group*]
#     The group owner of the homedir.
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
define sshkeys::create_ssh_key (
  $owner          = undef,
  $group          = undef,
  $create_ssh_dir = true,
  $ssh_keytype    = 'rsa',
  $passphrase     = ''
) {

  $homedir = getvar("::home_${name}")

  if $owner {
    $owner_real = $owner
  } else {
    $owner_real = $name
  }

  if $group {
    $group_real = $group
  } else {
    $group_real = $name
  }

  if $create_ssh_dir {
    file { "${homedir}/.ssh":
      ensure  => directory,
      owner   => $owner_real,
      group   => $group_real,
      mode    => '0700',
    }
    $require_home = File["${homedir}/.ssh"]
  } else {
    $require_home = undef
  }

  exec { "ssh_keygen-${name}":
    command => "/usr/bin/ssh-keygen -t ${ssh_keytype} -f '${homedir}/.ssh/id_${ssh_keytype}' -N '${passphrase}' -C '${name}@${::fqdn}'",
    user    => $name,
    creates => "${homedir}/.ssh/id_${ssh_keytype}",
    require => $require_home,
  }

}

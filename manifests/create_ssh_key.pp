# == Defined Type: sshkeys::create_ssh_key
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
#   [*bit_length*]
#     Optional bit length for key.
#     Defaults to 2048 for rsa and 1024 for dsa.
#
define sshkeys::create_ssh_key (
  $owner          = undef,
  $group          = undef,
  $create_ssh_dir = true,
  $ssh_keytype    = 'rsa',
  $ssh_bitlength  = undef,
  $passphrase     = '',
) {

  validate_bool($create_ssh_dir)
  validate_string($ssh_keytype)

  $homedir = getvar("::home_${name}")

  # Set $bitlength to default if no value provided
  $rsa_default = '2048'
  $dsa_default = '1024'

  if $ssh_bitlength {
    $bitlength = $ssh_bitlength
  }
  else {
    case $ssh_keytype {
      'rsa': {
        $bitlength = $rsa_default
      }
      'dsa': {
        $bitlength = $dsa_default
      }
      default: {
        fail('The sshkeys module currently supports only rsa or dsa default bit lengths')
      }
    }
  }

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
      ensure => directory,
      owner  => $owner_real,
      group  => $group_real,
      mode   => '0700',
    }
    $require = File["${homedir}/.ssh"]
  } else {
    $require = undef
  }

  exec { "ssh_keygen-${name}":
    command => "/usr/bin/ssh-keygen -t ${ssh_keytype} -b ${bitlength} -f '${homedir}/.ssh/id_${ssh_keytype}' -N '${passphrase}' -C '${name}@${::fqdn}'",
    user    => $name,
    creates => "${homedir}/.ssh/id_${ssh_keytype}",
    require => $require,
  }
}

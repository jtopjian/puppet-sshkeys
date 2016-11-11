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
#   [*ssh_dir*]
#     Directory where the key will be created. Defaults to '~user/.ssh'.
#     Also allows to create the user and the key in the same agent run
#     (when the user was just created, the home dir fact is not available
#     before the next run)
#
#   [*create_ssh_dir*]
#     Whether to create the directory.
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
  $ssh_dir        = undef,
  $create_ssh_dir = true,
  $ssh_keytype    = 'rsa',
  $ssh_bitlength  = undef,
  $passphrase     = '',
  $require        = undef,
) {

  validate_bool($create_ssh_dir)
  validate_string($ssh_keytype)

  if ($ssh_dir != undef) {
    $dir = $ssh_dir
  } else {
    $homedir = getvar("::home_${name}")
    if ($homedir == undef) {
	  notify { "Cannot determine the home dir of user '${name}'. Skipping SSH key creation": }
	  $dir = undef
	} else {
	  $dir = "${homedir}/.ssh"
	}
  }

  if ($dir != undef) {  
    # Set $bitlength to default if no value provided
    $rsa_default = '2048'
    $dsa_default = '1024'
  
    if $ssh_bitlength {
      $bitlength = $ssh_bitlength
    } else {
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
      file { "${dir}":
        ensure => directory,
        owner  => $owner_real,
        group  => $group_real,
        mode   => '0700',
		require => $require,
      }
	  if ($require == undef) {
		$required = File["${dir}"]
      } else {
		$required = [ $require, File["${dir}"] ].flatten
	  }
    } else {
      $required = $require
    }
  
    exec { "ssh_keygen-${name}":
      command => "/usr/bin/ssh-keygen -t ${ssh_keytype} -b ${bitlength} -f '${dir}/id_${ssh_keytype}' -N '${passphrase}' -C '${name}@${::fqdn}'",
      user    => $name,
      creates => "${dir}/id_${ssh_keytype}",
      require => $required,
    }
  }
}

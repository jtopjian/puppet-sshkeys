define sshkeys::set_authorized_key (
  $local_user,
  $remote_user,
  $ensure  = 'present',
  $group   = undef,
  $home    = undef,
  $options = undef,
  $target  = undef
) {

  # Parse the name
  $parts = split($remote_user, '@')
  $remote_user = $parts[0]
  $remote_node = $parts[1]

  # Figure out the destination home directory
  if ($home) {
    $home_real = $home
  } else {
    $home_real = "/home/${local_user}"
  }

  # Figure out the target
  if ($target) {
    $target_real = $target
  } else {
    $target_real = "${home_real}/.ssh/authorized_keys"
  }

  Ssh_authorized_key {
    user   => $local_user,
    target => $target_real,
  }
  if ($ensure == 'absent') {
    ssh_authorized_key { $name:
      ensure => absent,
    }
  } else {
    # Get the key
    $key = query_facts("fqdn=\"${remote_node}\"", ["sshkey_${remote_user}"])
    if ($key !~ /^(ssh-...)) {
      err("Can't parse key from ${remote_user}")
      notify { "Can't parse key from ${remote_user}. Skipping": }
    } else {
      $keytype = $1
      $modulus = $2
      ssh_authorized_key { $name:
        ensure  => $ensure,
        type    => $keytype,
        key     => $modulus,
        options => $options ? { undef => undef, default => $options },
      }
    }
  }
}

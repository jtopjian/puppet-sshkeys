# == Defined Type: sshkeys::set_authorized_key
#
#   Add a key to a user's authorized_keys file.
#
# === Parameters
#
#   [*local_user*]
#     The user who will receive the key.
#
#   [*remote_user*]
#     The user of the key being obtained.
#
#   [*ensure*]
#     Status of the key.
#
#   [*group*]
#     Group owner of the key.
#
#   [*home*]
#     The homedir of the user receiving the key.
#
#   [*options*]
#     Any ssh key options.
#
#   [*target*]
#     The destination authorized_keys file.
#
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
  $remote_username = $parts[0]
  $remote_node     = $fqdn

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
    $results = query_facts("fqdn=\"${remote_node}\"", ["sshpubkey_${remote_username}"])
    if is_hash($results) and has_key($results, $remote_node) {
      $key = $results[$remote_node]["sshpubkey_${remote_username}"]
      if ($key !~ /^(ssh-...) ([^ ]*)/) {
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
    } else {
      notify { "Public key from ${remote_username}@${remote_node} not available yet. Skipping": }
    }
  }
}

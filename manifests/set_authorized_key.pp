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
  $options = undef,
  $target  = undef
) {

  # Parse the name
  $parts = split($remote_user, '@')
  $remote_username = $parts[0]
  $remote_node     = downcase($parts[1])

  $home = getvar("::home_${local_user}")
  if ($home == undef) {
    notify { "Cannot determine the home dir of user '${local_user}'. Skipping SSH authorized key registration": }
  } else {
    # Figure out the target
    if $target {
      $target_real = $target
    } else {
      $target_real = "${home}/.ssh/authorized_keys"
    }
    
    Ssh_authorized_key {
      user   => $local_user,
      target => $target_real,
    }
    
    if $ensure == 'absent' {
      ssh_authorized_key { $name:
        ensure => absent,
      }
    } else {
      # Get the key
      if $remote_node =~ /\./ {
        $results = query_facts("fqdn=\"${remote_node}\"", ["sshpubkey_${remote_username}"])
      } else {
        $results = query_facts("hostname=\"${remote_node}\"", ["sshpubkey_${remote_username}"])
      }
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
            options => $options,
          }
        }
      } else {
        notify { "Public key from ${remote_username}@${remote_node} (for local user ${local_user}) not available yet. Skipping": }
      }
    }
  }
}

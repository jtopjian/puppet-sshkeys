# == Defined Type: sshkeys::create_ssh_directory
#
#   Creates a .ssh directory for a given user.
#
# === Parameters
#
#   [*home*]
#     The homedir to create the directory in.
#
#   [*require_user*]
#     Whether to depend on a User resource or not.
#
define sshkeys::create_ssh_directory (
  $home         = undef,
  $require_user = true
) {

  if $home {
    $home_real = $home
  } else {
    $home_real = "/home/${name}"
  }

  $require = $require_user ? {
    true  => [File[$home_real], User[$name]],
    false => File[$home_real],
  }

  file { "${home_real}/.ssh":
    ensure  => directory,
    owner   => $name,
    mode    => '0700',
    require => $require,
  }
}

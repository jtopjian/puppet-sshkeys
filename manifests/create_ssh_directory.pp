define sshkeys::create_ssh_directory (
  $home         = undef,
  $manage_home  = true,
  $require_user = true
) {

 if ($home) {
    $home_real= $home
  } else {
    $home_real= "/home/${name}"
  }

  $require = $require_user ? {
    true  => [File[$home_real], User[$name]],
    false => File[$home_real],
  }

  file { "${home_real}/.ssh":
    ensure  => directory,
    mode    => '0700',
    require => $require,
  }
}

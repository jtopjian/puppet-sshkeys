define sshkeys::create_key (
  $home           = undef,
  $require_user   = false,
  $manage_home    = true,
  $create_ssh_dir = true,
  $passphrase     = ''
) {

  if ($home) {
    $home_real = $home
  } else {
    $home_real = "/home/${name}"
  }

  if ($create_ssh_dir) {
    sshkeys::create_ssh_directory { $name:
      home         => $home_real,
      require_user => $require_user,
    }
    $require1 = [File["${home_real}/.ssh"]]
  } else {
    $require1 = []
  }

  if ($require_user) {
    $require2 = concat($require1, [User[$name]])
  } else {
    $require2 = $require1
  }

  if ($manage_home) {
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
    command => "/usr/bin/ssh-keygen -f \"${home_real}/.ssh/id_rsa\" -N '${passphrase}' -C '${user}@${::fqdn}'",
    user    => $name,
    creates => "${home_real}/.ssh/id_rsa",
    require => $require3,
  }
}

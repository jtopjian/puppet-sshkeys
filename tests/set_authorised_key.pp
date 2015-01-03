sshkeys::set_authorized_key { 'root@server1 to root@server2':
  local_user  => 'root',
  remote_user => 'root@server1',
}

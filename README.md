sshkeys puppet module
=====================

The sshkeys puppet module creates, shares, and installs SSH keys.


Important!
==========

This module recently went through a large change and is not compatible
with previous versions.

You can access the old version in the v1 branch or the 1.0.0 tag.

How it works
============

Contrary to other ssh puppet modules, keys are managed locally on each
Puppet node and shared via Facter. This requires PuppetDB.

One limitation is that only the default `id_rsa` or `id_dsa` public key
is shared -- this module is unable to handle multiple keys at this time.

Usage
=====

Create a SSH key for a user:

```puppet
sshkeys::create_key { 'root':
  home     => '/root',
  ssh_keytype => 'dsa',
}
```

Once created, Facter will expose the public key via the fact `sshpubkey_root`.

To allow `root@server1` to access `root@server2`:

```puppet
sshkeys::set_authorized_key {'root@server1 to root@server2':
  local_user  => 'root',
  remote_user => 'root@server1',
  home        => '/root',
}
```

Now, `user1` should have the `key1` key pair installed on his account,
and be able to login to the `user2` account.

Dependencies
============

This module requires:

  * The [dalen/puppetdbquery](https://github.com/dalen/puppet-puppetdbquery) module
  * The `concat` function added to [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib) in version 4.1.0


Authors
=======

This module was lightly based off of Boklm's
[module](https://github.com/boklm/puppet-sshkeys). I used this module
frequently before changing to a PuppetDB/Facter-based solution. Some
of the code was used in my version.

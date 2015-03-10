sshkeys puppet module
=====================

The sshkeys puppet module creates, shares, and installs SSH keys.

Important!
==========

This module recently went through a large change and is not compatible with previous versions.

You can access the old version in the v1 branch or the 1.0.0 tag.

How it works
============

This module contains two facts:

### sshpubkey_

This fact publishes all default SSH keys for all users found in `/etc/passwd`.

By using PuppetDB, all keys are then recorded in the database. Other nodes (and tools) are then able to query PuppetDB and obtain the public key for the user.

### home_

This fact publishes the homedir for all users found in `/etc/passwd`. This fact is used to help locate a certain user's home directory.

In addition to those two facts, an optional third fact can be created:

```shell
$ cat /etc/facter/facts.d/homedir_users.yaml
---
homedir_users:
  - root
  - jdoe
```

If this fact exists, then only the users specified will have their home directory and ssh public key exported via facter. This is useful in cases where `/home` is automounted and parsing all users will mount all home directories. It's also useful if you just don't want everyone's public key exported.

Limitations
===========

* Only the default `id_rsa` or `id_dsa` public key is shared -- this module is unable to handle multiple keys at this time.
* Users are expected to be managed _outside_ of this module.

Usage
=====

Create a SSH key for a user (this is optional):

```puppet
sshkeys::create_ssh_key { 'root':
  ssh_keytype => 'dsa',
}
```

The default bit lengths are 2048 for rsa and 1024 for dsa.  To override the defaults, use the ssh_bitlength parameter.

Once created, Facter will expose the public key via the fact `sshpubkey_root`.

To allow `root@server1` to access `root@server2`:

```puppet
sshkeys::set_authorized_key { 'root@server1 to root@server2':
  local_user  => 'root',
  remote_user => 'root@server1',
}
```

Now, `root@server2` will have `root@server1`'s public key added to its `~/.ssh/authorized_keys` file thus allowing `root@server1` to log into `server2` as `root` without a password.

Dependencies
============

This module requires:

  * The [dalen/puppetdbquery](https://github.com/dalen/puppet-puppetdbquery) module

Credits
=======

This module was lightly based off of Boklm's [module](https://github.com/boklm/puppet-sshkeys). I used this module frequently before changing to a PuppetDB/Facter-based solution. Some of the code was used in my version.

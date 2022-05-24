# Shell Jail
A small script to outfit an empty [BastilleBSD](https://bastillebsd.org) jail in order to run the /bin/sh shell

#### Why no Bastillefile?

Bastillefiles are a great way to provision jails, however Bastille will not apply templates to a stopped jail
and an empty jail cannot be started, so we have to bootstrap it the old fashioned way.

## Usage

Call this script with the full path to your jail and the IP address you want to use.

```
./sh-jail jail_name ip.ad.dr.ess
```

This uses the default `bastille0` shared interface.

You may specify an alternative as the final parameter.

```
./sh-jail jail_name ip.ad.dr.ess bridge0
```

The script will create an empty Bastille jail and set it up with the bare minimum structure and binaries to run a shell.

Connect into your new jail:

```
bastille start jail_name
```

When you exit the jail will die.

**Note:**
When restarting the jail you may see an error saying the IP is in use, you must remove the jail ip manually:

```
ifconfig bastille0 delete ip.ad.dr.ess
```

For some reason this is not run by `exec.release` in jail.conf.

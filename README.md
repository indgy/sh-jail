# Shell Jail
A small script to outfit an empty BastilleBSD jail in order to run the /bin/sh shell

It is not possible to run a Bastillefile to provison an empty jail as an empty jail cannot
be started and Bastille will not apply templates to a stopped jail.

## Usage

Call this script with the full path to your jail and the IP address you want to use.

```
./sh-jail jail_name ip.ad.dr.ess
```

Make any further changes required in jail.conf

Then start the jail and open the shell:

```
bastille start jail_name
```

When you exit the console the jail will die.

**Note:**
You may see an error when restarting the jail saying the IP is in use, you must
remove the jail ip manually, for some reason this is not run by `exec.release`:

```
ifconfig bastille0 delete ip.ad.dr.ess
```

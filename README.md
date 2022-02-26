# UrNVR

Unlock the full potential of your UNVR

### :warning: :warning: :warning: :warning: :warning: :warning: :warning: :warning: :warning:
### This may brick your device and void your warranty. Any use of these tools and instructions is completely at your own risk!
### Make sure that you have no important data on any of the hard drives attached to the UNVR. Depending on your setup it may not be accessible after the changes described here.
### :warning: :warning: :warning: :warning: :warning: :warning: :warning: :warning: :warning:

## Compilation

Assuming you have a linux system with regular build tools, follow these steps (a cross compiler will be automatically built for you)

```
# clone the git directory and enter it
git clone --recurse-submodules https://github.com/UrNVR/urnvr
cd urnvr

# If you want to modify the buildroot configuration (skip otherwise)
make buildroot-menuconfig

# If you want to modify the kernel configuration (skip otherwise)
make kernel-menuconfig

# Compile everything
make
```

## Installation

- Make sure there are no harddrives installed in your UNVR.
- If your UNVR has been used with Ubiquiti software, make sure that firmware version 2.3.14 is installed.
- Find out the IP of your UNVR. 
- Connect via SSH (e.g. `ssh root@un.vr.i.p`). If you did not change the password, it should still be `ubnt`.
- If your UNVR is fresh from the box, now is your time to make sure that firmware version 2.3.14 is installed (I don't remember the name of the necessary command at the moment).
- Make full backups of `/dev/mtd*` and `/dev/boot` using `dd` via `ssh` (e.g. `ssh root@un.vr.i.p dd if=/dev/boot | dd of=backup_boot`, repeat for ´/dev/mtd1´, ´/dev/mtd2´, ´/dev/mtd3´, ...).
- Compile using the instructions above.
- Mount `/dev/boot1` to a location of your choice (e.g. `mkdir /tmp/boot; mount /dev/boot1 /tmp/boot`).
- Configure a copy of `urnvr.example.conf` per your needs (**don't enable setup, yet**) and use scp to place it in the boot directory (e.g. `scp my-urnvr.conf root@un.vr.i.p:/tmp/boot/urnvr.conf`).
- If there is no `uImage.bkp` where you mounted `/dev/boot1`, copy the original `uImage` over (e.g. `ssh root@un.vr.i.p cp /tmp/boot/uImage /tmp/boot/uImage.bkp`).
- You can place your own `interfaces.d` directory inside the mountpoint of  `/dev/boot1`, the defaults can be found in `src/urnvr-init/overlay/config/interfaces.d`.
- Copy uImage onto `/dev/boot1` (e.g. `scp uImage root@un.vr.i.p:/tmp/boot`).
- Restart your UNVR and wait for it to show up in your network.
- You should now be able to connect via SSH with password `urnvr`. If not, stop here and create an issue to get help unbricking your machine (this is especially important for users of the newer version!).
- Either enable setup in the config file on your PC and copy it over or use sed to enable it on the machine (the drive should automatically be mounted at `/boot`).
- Make sure the selected interface is connected to a network that has a DHCP server and internet access. (You won't need to ssh into it at the moment)
- Reboot the UNVR and give it some time to download the rootfs.
- If your computer and UNVR are on the same network (and you used the default settings), you know that it is done when the machine is available via SSH.

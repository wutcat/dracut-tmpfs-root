dracut-tmpfs-root
=================

This is a dracut module to allow for booting to a tmpfs root created by extracting an archive (currently only tar.gz).

* A simplified breakdown of the process
  1. Make a temporary directory to mount the source volume
  2. Mount a tmpfs filesystem on `/sysroot`
  3. Untar the archive from the source volume to `/sysroot`
  4. Unmount the source volume
  5. Execute switch-root to `/sysroot`

Install the module
------------------
Simply drop the `90tmpfs-root` directory into your dracut modules directory. On CentOS/RHEL, this directory is `/usr/lib/dracut/modules.d`.

Use the module in an initrd image
--------------------------
You must modify the dracut command slightly to include the module:
```bash
dracut -N -a tmpfs-root -f /boot/initrd-tmpfs.img
```
- `-N` builds a non-host-only initrd (TODO: this requirement may be removed in the future)
- `-a` tells dracut to include the tmpfs-root module
- `-f` is, of course, the output image file

Create a suitable image archive
-------------------------------

How you get your image is up to you. For KVM VMs, you can use guestfish:
```shell
guestfish --ro -a /work/disk.img -i copy-out / /work/newroot/
tar czpf /work/rootfs.tar.gz
```

Kernel cmdline arguments
------------------------
All are required. (TODO: Sane defaults)
- `root`: This takes a special syntax which this modules uses to hijack the root mount process: `root=tmpfs:/dev/vda1`
- `rd.tmpfs.imgfile`: The relative path to the archive file on the volume set for `root`.
- `rd.tmpfs.size`: The size of the tmpfs root filesystem. For a description of the `size` mount arguments, see https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt

A sample kernel cmdline with tmpfs root
```shell
linux16 /vmlinuz-3.10.0-693.11.6.el7.x86_64 root=tmpfs:/dev/vda1 rd.tmpfs.size=3G rd.tmpfs.imgfile=rootfs.tgz ro crashkernel=auto rhgb LANG=en_US.UTF-8
```
Using an LVM volume
```shell
linux16 /vmlinuz-3.10.0-693.11.6.el7.x86_64 root=tmpfs:/dev/mapper/centos-root rd.tmpfs.size=5G rd.tmpfs.imgfile=images/rootfs.tar.gz rd.lvm.lv=centos/root ro crashkernel=auto rhgb LANG=en_US.UTF-8
```
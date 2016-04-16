% Custom Arch Linux Live USB Build

run (as root) :
```
    # cp -r /path/to/cloned/folder arch-build
    # cd arch-build
    # grep -v "#" packages.install | sort -ur | tee packages.x86_64
    # ./build.sh -v
```

output iso in `work` folder, which can be written onto usb disk (/dev/sdX) :

```
    # dd if=/path/to/built/iso of=/dev/sdX bs=4M && sync
```

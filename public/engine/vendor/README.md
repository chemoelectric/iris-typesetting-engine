# Vendor Libraries

## `libkpathsea` Source Distribution Tarball
If your build environment lacks a pre-installed `libkpathsea` library (`libkpathsea.a` or `libkpathsea.so`), a bundled upstream source tarball `libkpathsea.tar.xz` can be placed in this directory.

To build and install `libkpathsea` from the bundled source tarball:
```sh
tar -xf vendor/libkpathsea.tar.xz -C /tmp/
cd /tmp/kpathsea-*
./configure --prefix=/usr/local
make && sudo make install
```
Then re-run `./configure` for Iris.

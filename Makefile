# This applies a simple hack to the nemo file browser to sort underscores first, as known from the Windows file explorer.
# This Makefile automatically downloads, patches, builds and installs the hacked version of the nemo file browser on your system.
# Tested in Ubuntu 20.04 (64-bit)

# For the usual steps after installation, see:
#     https://wiki.ubuntuusers.de/Nemo/
# (Of course, skip the initial  "sudo apt-get install nemo" )

# To fix the theming issues, see:
#     https://www.linuxuprising.com/2018/07/how-to-replace-nautilus-with-nemo-file.html

all:
	@echo "Usage:"
	@echo "    make prepare | patch | build | clean | uninstall | install | debug | rebuild_cycle"
	@echo ""
	@echo "Usually, you'll want to run:  make prepare patch build uninstall install debug"
	@echo "However, for debugging, run:  make rebuild_cycle"

build: build-xapp build-nemo

clean: 
	sudo rm -f build/*.deb

uninstall:
	sudo apt purge nemo -y

install: install-xapp install-nemo

prepare:
	mkdir build

	sudo apt install libdbusmenu-gtk3-dev python-gi-dev valac

	cd build ; git clone https://github.com/linuxmint/xapp.git

	# This optionally checks out the version of xapp I initially tested this hack with:
	#cd build/xapp/ ; git checkout 479b96e

	sudo apt install debhelper dh-python gobject-introspection gtk-doc-tools intltool itstool libatk1.0-dev libcinnamon-desktop-dev libexempi-dev libexif-dev libgail-3-dev libgirepository1.0-dev libglib2.0-dev libglib2.0-doc libgtk-3-dev libgtk-3-doc libnotify-dev libxapp-dev libxml2-dev meson

	cd build ; git clone https://github.com/linuxmint/nemo.git

	# This optionally checks out the version of nemo I initially tested this hack with:
	#cd build/nemo/ ; git checkout 22a0368

	sudo apt install devscripts

_make_patch_:
	# This is just for me to create a fresh patch file from local copies after debugging.
	diff -u nemo-file.c nemo-file-hack.c > nemo-file.patch

patch:
	patch build/nemo/libnemo-private/nemo-file.c nemo-file.patch

build-xapp:
	# -j12: Using 12 cores
	cd build/xapp/ ; debuild -b -uc -us -j12

install-xapp:
	sudo dpkg -i build/xapps-common_1.9.0_all.deb
	sudo dpkg -i build/libxapp1_1.9.0_amd64.deb
	sudo dpkg -i build/libxapp-dbg_1.9.0_amd64.deb
	sudo dpkg -i build/gir1.2-xapp-1.0_1.9.0_amd64.deb
	sudo dpkg -i build/libxapp-dev_1.9.0_amd64.deb

build-nemo:
	# -j12: Using 12 cores
	cd build/nemo ; debuild -b -uc -us -j12

install-nemo:
	sudo dpkg -i build/nemo-data_4.6.5_all.deb
	sudo dpkg -i build/libnemo-extension1_4.6.5_amd64.deb
	sudo dpkg -i build/nemo_4.6.5_amd64.deb
	sudo dpkg -i build/nemo-dbg_4.6.5_amd64.deb

debug:
	pkill nemo || true
	NEMO_DEBUG=all nemo --debug

rebuild_cycle: uninstall clean build-nemo install-nemo debug

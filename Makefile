obj-m += nv_peer_mem.o

#
# Do 'make OFA_KERNEL=/pathto/compat-rdma' if building
# on top of an OFED-3.x installation.
#

PWD  := $(shell pwd)
KVER := $(shell uname -r)
MODULES_DIR := /lib/modules/$(KVER)
KDIR := $(MODULES_DIR)/build
MODULE_DESTDIR := $(MODULES_DIR)/extra/
DEPMOD := depmod

EXTRA_CFLAGS += $(PROFILE) -D_KERNEL_

KERNEL_VER?=$(shell uname -r)

ifneq ($(OFA_KERNEL),)
	MODFILE := $(OFA_KERNEL)/Module.symvers
        EXTRA_CFLAGS +=-I$(OFA_KERNEL)/include/ -I$(OFA_KERNEL)/include/rdma -D__OFED_BUILD__

        VERSION_H := $(KDIR)/include/linux/version.h
        ifeq ($(wildcard $(VERSION_H)),)
          VERSION_H := $(KDIR)/include/generated/uapi/linux/version.h
        endif

        AUTOCONF_H := $(KDIR)/include/linux/autoconf.h
        ifeq ($(wildcard $(AUTOCONF_H)),)
          AUTOCONF_H := $(KDIR)/include/generated/autoconf.h
        endif

        #
        # If compat_autoconf.h exists then we're dealing with OFED-3.x.
        # We must include this file, which also requires including
        # the main autoconf.h and version.h prior to compat_autoconf.h
        #
        COMPAT_AUTOCONF_H := $(OFA_KERNEL)/include/linux/compat_autoconf.h
        ifneq ($(wildcard $(COMPAT_AUTOCONF_H)),)
          AUTOCONFS := -include $(VERSION_H) -include $(AUTOCONF_H) -include $(COMPAT_AUTOCONF_H)
        endif

        FOO := $(AUTOCONFS) -I$(OFA_KERNEL)/include $(LINUXINCLUDE)
        override LINUXINCLUDE=$(FOO)
else
	MODFILE := $(KDIR)/Module.symvers
endif

all:
	cp -rf $(MODFILE) Module.symvers
	cat nv.symvers >> Module.symvers
	make -C $(KDIR) M=$(PWD) NOSTDINC_FLAGS="$(EXTRA_CFLAGS)" modules

clean:
	make -C $(KDIR)  M=$(PWD) clean

install:
	mkdir -p $(MODULE_DESTDIR);
	cp -f $(PWD)/nv_peer_mem.ko $(MODULE_DESTDIR);
	$(DEPMOD) -r -ae $(KVER)

uninstall:
	/bin/rm -f $(MODULE_DESTDIR)/nv_peer_mem.ko
	$(DEPMOD) -r -ae $(KVER)

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


KERNEL_VER?=$(shell uname -r)

ifneq ($(OFA_KERNEL),)
        EXTRA_CFLAGS +=-I$(OFA_KERNEL)/include/ -I$(OFA_KERNEL)/include/rdma
	MODFILE := $(OFA_KERNEL)/Module.symvers
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

obj-m += nv_peer_mem.o

#OFA_KERNEL=$(shell (test -d /usr/src/ofa_kernel/default && echo /usr/src/ofa_kernel/default) || (test -d /var/lib/dkms/mlnx-ofed-kernel/ && ls -d /var/lib/dkms/mlnx-ofed-kernel/*/build))

EXTRA_CFLAGS +=-I$(OFA_KERNEL)/include/ -I$(OFA_KERNEL)/include/rdma
PWD  := $(shell pwd)
KVER := $(shell uname -r)
MODULES_DIR := /lib/modules/$(KVER)
KDIR := $(MODULES_DIR)/build
MODULE_DESTDIR := $(MODULES_DIR)/extra/
DEPMOD := depmod


KERNEL_VER?=$(shell uname -r)
all:
	cp -rf $(KDIR)/Module.symvers .
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

prefix = /usr/local
binaries = libnss_puavoadmins.so.2 \
	puavoadmins-ssh-authorized-keys \
	puavoadmins-validate-orgjson

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

all: $(binaries)

puavoadmins-validate-orgjson: puavoadmins-validate-orgjson.o orgjson.o
	gcc -o $@ $^ -ljansson -lm

puavoadmins-ssh-authorized-keys: puavoadmins-ssh-authorized-keys.o orgjson.o
	gcc -o $@ $^ -ljansson -lm

libnss_puavoadmins.so.2: passwd.o group.o orgjson.o
	gcc -shared -o $@ -Wl,-soname,$@ $^ -ljansson -lm

%.o: %.c %.h common.h
	gcc -g -fPIC -std=gnu99 -Wall -Wextra -c $< -o $@

%.o: %.c common.h
	gcc -g -fPIC -std=gnu99 -Wall -Wextra -c $< -o $@

installdirs:
	mkdir -p $(DESTDIR)$(prefix)/lib

install: installdirs all
	$(INSTALL_PROGRAM) -t $(DESTDIR)$(prefix)/lib \
		libnss_puavoadmins.so.2 \
		puavoadmins-mkhomes \
		puavoadmins-ssh-authorized-keys \
		puavoadmins-update-orgjson \
		puavoadmins-validate-orgjson

clean:
	rm -rf *.o
	rm -rf $(binaries)

deb :
	rm -rf debian
	cp -a debian.default debian
	puavo-dch $(shell cat VERSION)
	dpkg-buildpackage -us -uc

.PHONY: all installdirs install clean deb

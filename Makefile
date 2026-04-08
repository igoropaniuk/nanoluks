PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin

.PHONY: install uninstall

install:
	install -Dm755 nanoluks $(DESTDIR)$(BINDIR)/nanoluks

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/nanoluks

PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin

.PHONY: install uninstall lint test

install:
	install -Dm755 nanoluks $(DESTDIR)$(BINDIR)/nanoluks

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/nanoluks

# Static lint: shellcheck and ASCII-only enforcement.
lint:
	@set -e; \
	echo ":: shellcheck"; \
	shellcheck nanoluks; \
	echo ":: ASCII check"; \
	if grep -rPn '[^\x00-\x7F]' nanoluks README.md; then \
		echo "Non-ASCII characters found"; exit 1; \
	fi; \
	echo ":: lint passed"

# Full create/open/write/close lifecycle. Mounts a real filesystem under
# /mnt/nanoluks, so the recipe self-elevates with sudo if not already
# root - this avoids the catch-22 where `setsid -w` (used so nanoluks
# reads the piped passphrase from stdin instead of /dev/tty) would also
# strip the tty sudo needs to prompt for a password. CI's runner has
# passwordless sudo, so the same `make test` works there unattended.
test:
	@if [ "$$(id -u)" -ne 0 ]; then exec sudo $(MAKE) test; fi; \
	set -e; \
	echo ":: cleaning up any prior state"; \
	umount /mnt/nanoluks/make-test-fixture 2>/dev/null || true; \
	cryptsetup close nanoluks-make-test-fixture 2>/dev/null || true; \
	rm -f /tmp/make-test-fixture.img; \
	echo ":: integration test"; \
	printf 'testpassword\ntestpassword\n' | setsid -w ./nanoluks create /tmp/make-test-fixture.img --size 50M --fs ext4; \
	printf 'testpassword\n' | setsid -w ./nanoluks open /tmp/make-test-fixture.img; \
	mountpoint -q /mnt/nanoluks/make-test-fixture; \
	echo "hello from nanoluks" > /mnt/nanoluks/make-test-fixture/test.txt; \
	grep -q "hello from nanoluks" /mnt/nanoluks/make-test-fixture/test.txt; \
	./nanoluks close /tmp/make-test-fixture.img; \
	if mountpoint -q /mnt/nanoluks/make-test-fixture 2>/dev/null; then \
		echo "ERROR: still mounted after close"; exit 1; \
	fi; \
	if [ -e /dev/mapper/nanoluks-make-test-fixture ]; then \
		echo "ERROR: mapper still present after close"; exit 1; \
	fi; \
	rm /tmp/make-test-fixture.img; \
	echo ":: integration test passed"

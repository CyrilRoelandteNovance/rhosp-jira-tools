PREFIX ?= /usr/local
scripts=bin/add-missing-workstream

install: $(scripts)
	install -d $(PREFIX)/bin/
	for script in $^; do \
		install -m 644 $$script $(PREFIX)/bin/; \
	done

uninstall:
	for script in $(scripts); do \
		rm -f $(PREFIX)/$$script; \
	done

check:
	tests/test-add-missing-workstream.sh

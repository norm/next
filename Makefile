all:

test:
	bats tests/*.bats

install:
	install next.sh /usr/local/bin/next


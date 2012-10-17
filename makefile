.PHONY: test

test:
	rm test.html
	perl mps.pl > test.html

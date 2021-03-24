COUNTRY_CODE?=US

clean:
	@rm -rf /tmp/work

build: clean
	@mkarchiso -v -w /tmp/work -o /tmp ./arch

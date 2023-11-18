COUNTRY_CODE?=US

clean:
	@rm -rf /arch-server/w

build: clean
	@mkdir -p /arch-server/w
	@mkarchiso -v -w /arch-server/w -o /arch-server ./arch

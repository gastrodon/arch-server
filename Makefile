COUNTRY_CODE?=US

clean:
	@rm -rf /arch-server/build

build: clean
	@mkdir -p /arch-server/build
	@mkarchiso -v -w /arch-server/build -o /tmp ./arch

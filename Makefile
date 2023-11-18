COUNTRY_CODE?=US

clean:
	@rm -rf /arch-server/build

build: clean
	@mkarchiso -v -w /arch-server/build -o /tmp ./arch

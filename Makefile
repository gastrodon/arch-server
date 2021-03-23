COUNTRY_CODE?=US

build:
	@mkarchiso -v -w /tmp/work -o ./out ./arch

COUNTRY_CODE?=US

clean:
	@rm -rf ./build/work

clean-iso:
	@rm -rf ./build/*.iso

gen-mirrorlist:
	@mkdir -p ./arch/airootfs/etc/pacman.d
	@reflector --latest 10 --sort rate --save ./arch/airootfs/etc/pacman.d/mirrorlist

build: clean clean-iso gen-mirrorlist
	@mkarchiso -v -w ./build/work -o ./build ./arch

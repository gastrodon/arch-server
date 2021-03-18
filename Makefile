HASH=`openssl passwd -6`
COUNTRY_CODE?=US

clean:
	@echo root::14871:::::: > ./arch/airootfs/etc/shadow
	@rm -rf ./build/work

clean-iso:
	@rm -rf ./build/*.iso

gen-passwd:
	@echo 'Password for account "zero"'
	@echo "zero:${HASH}:14871::::::" >> ./arch/airootfs/etc/shadow

gen-mirrorlist:
	@mkdir -p ./arch/airootfs/etc/pacman.d
	@reflector --latest 10 --sort rate --save ./arch/airootfs/etc/pacman.d/mirrorlist

build: clean clean-iso gen-passwd gen-mirrorlist
	@mkarchiso -v -w ./build/work -o ./build ./arch

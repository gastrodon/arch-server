HASH=$(shell openssl passwd -6)
COUNTRY_CODE?=US

p:
	echo $(reflector_country)

clean:
	rm -rf ./build/work

clean-all:
	rm -rf ./build/*

gen-passwd:
	printf "root::14871::::::\nzero:$(HASH):14871::::::\n" \
		> ./arch/airootfs/etc/shadow

gen-mirrorlist:
	mkdir -p ./arch/airootfs/etc/pacman.d
	reflector --latest 10 --sort rate --save ./arch/airootfs/etc/pacman.d/mirrorlist

build: clean-all gen-passwd gen-mirrorlist
	mkarchiso -v -w ./build/work -o ./build ./arch

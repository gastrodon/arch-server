HASH=`openssl passwd -6`
COUNTRY_CODE?=US

clean:
	rm -rf ./build/work

clean-all:
	rm -rf ./build/*

gen-passwd:
	echo "zero:${HASH}:14871::::::" >> ./arch/airootfs/etc/shadow

gen-mirrorlist:
	mkdir -p ./arch/airootfs/etc/pacman.d
	reflector --latest 10 --sort rate --save ./arch/airootfs/etc/pacman.d/mirrorlist

build: clean-all gen-passwd gen-mirrorlist
	mkarchiso -v -w ./build/work -o ./build ./arch

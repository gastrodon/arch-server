COUNTRY_CODE?=US

clean:
	@rm -rf ./build/work

clean-iso:
	@rm -rf ./build/*.iso

build: clean 
	@mkarchiso -v -w ./build/work -o ./build ./arch

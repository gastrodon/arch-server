COUNTRY_CODE?=US

clean:
	@rm -rf /arch-server/w

build: clean
	@mkdir -p /arch-server/w 
	@mkarchiso -v -w /arch-server/w -o /arch-server ./arch

release: build
	VERSION := $(git describe --tags)
	
	@git describe --tags
	@[ -z "$(git status --porcelain)" ]
	@mkdir -p /arch-server/build
	@mv /arch-server/arch-server-latest-x86_64.iso /arch-server/build/arch-server-$(VERSION)-x86_64.iso
	@ln -s /arch-server/build/arch-server-$(VERSION)-x86_64.iso /arch-server/build/arch-server-latest-x86_64.iso
build:
	nasm -g -f macho64 life.asm -l life.list
	ld -arch x86_64 -platform_version macos 11.0 11.0 -no_pie -L$$(xcrun --show-sdk-path)/usr/lib -lSystem -o life life.o
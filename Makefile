build:
	nasm -f macho64 life.asm
	ld -macosx_version_min 10.7.0 -no_pie -o life life.o

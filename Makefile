build:
	nasm -g -f macho64 life.asm -l life.list
	ld -macosx_version_min 10.7.0 -no_pie -o life life.o

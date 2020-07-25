build:
	nasm -g -f macho64 life.asm -l life.list
# 	clang msws.c -c -o msws.o -m64
	ld -macosx_version_min 10.7.0 -no_pie -o life -lc life.o # msws.o

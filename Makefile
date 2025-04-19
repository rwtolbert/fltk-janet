LOCAL_JANET=${CURDIR}/local_janet_deps
LOCAL_JANET_LIB=${LOCAL_JANET}/lib
export JANET_PATH=${LOCAL_JANET_LIB}

ifeq ($(OS),Windows_NT)
	# SHELL := powershell.exe
	# .SHELLFLAGS := -NoProfile -Command
	PREFIX=${HOME}
	JANET_PM=${HOME}\\AppData\\Local\\Apps\\Janet\\Library\\bin\\janet-pm
	MD=powershell.exe -NoProfile -Command mkdir -force
	RM=powershell.exe -NoProfile -Command rm -r -force
	CP=powershell.exe -NoProfile -Command cp
	EXE=".exe"
	FLTK_FLAGS=-DFLTK_USE_SYSTEM_LIBJPEG=OFF -DFLTK_USE_SYSTEM_LIBPNG=OFF -DFLTK_USE_SYSTEM_ZLIB=OFF
	DLL=".dll"
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CP=cp
		FLTK_FLAGS=-DCFLTK_USE_FPIC=ON -DFLTK_USE_SYSTEM_LIBJPEG=OFF -DFLTK_USE_SYSTEM_LIBPNG=OFF -DFLTK_USE_SYSTEM_ZLIB=OFF
	else
		CP=cp -c
		FLTK_FLAGS=-DFLTK_USE_SYSTEM_LIBJPEG=OFF -DFLTK_USE_SYSTEM_LIBPNG=OFF -DFLTK_USE_SYSTEM_ZLIB=OFF
	endif
	PREFIX?=/usr/local
	JANET_PM=$(HOME)/dev/janet/lib/janet/bin/janet-pm
	MD=mkdir -p
	RM=rm -rf
	EXE=""
	DLL=".so"
endif

.PHONY: default
default: build

${LOCAL_JANET_LIB}:
	${MD} "${LOCAL_JANET_LIB}"

.PHONY: cfltk
cfltk:
	cmake -B cfltk-build -S cfltk -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCFLTK_USE_OPENGL=ON -DFLTK_BUILD_EXAMPLES=OFF ${FLTK_FLAGS}
	cd cfltk-build && make -j

.PHONY: deps
deps: ${LOCAL_JANET_LIB}
	@$(JANET_PM) deps

.PHONY: build
build: deps
	@$(JANET_PM) build
	@${CP} _build/release/jfltk${DLL} fltk-janet/

.PHONY: clean
clean:
	@$(JANET_PM) clean
	${RM} *.obj
	${RM} *.o

.PHONY: clean-all
clean-all: clean
	${RM} local_janet_deps
	${RM} bundle
	${RM} *.obj
	${RM} *.o

.PHONY: clean-deps
clean-deps:
	@$(JANET_PM) clear-cache


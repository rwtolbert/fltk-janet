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
else
PREFIX?=/usr/local
JANET_PM=$(HOME)/dev/janet/lib/janet/bin/janet-pm
MD=mkdir -p
RM=rm -rf
CP=cp
EXE=""
endif

.PHONY: default
default: build

${LOCAL_JANET_LIB}:
	${MD} "${LOCAL_JANET_LIB}"

.PHONY: cfltk
cfltk:
	cmake -B cfltk-build -S cfltk -G "Unix Makefiles" -DCFLTK_USE_OPENGL=ON
	cd cfltk-build && make -j

.PHONY: deps
deps: ${LOCAL_JANET_LIB}
	@$(JANET_PM) deps

.PHONY: build
build: deps
	@$(JANET_PM) build

# .PHONY: man
# man:
# 	@janet scripts/make_manpage.janet

# .PHONY: install
# install: build man
# 	${MD} $(PREFIX)/bin
# 	${CP} _build/release/jdg${EXE} $(PREFIX)/bin
# 	${MD} $(PREFIX)/man/man1
# 	${CP} jdg.1 $(PREFIX)/man/man1

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


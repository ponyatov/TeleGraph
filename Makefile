# \ var
# detect module/project name by current directory
MODULE  = $(notdir $(CURDIR))
# detect OS name (only Linux in view)
OS      = $(shell uname -s)
# current date in the `ddmmyy` format
NOW     = $(shell date +%d%m%y)
# release hash: four hex digits (for snapshots)
REL     = $(shell git rev-parse --short=4 HEAD)
# current branch
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
# number of CPU cores (for parallel builds)
CORES   = $(shell grep processor /proc/cpuinfo| wc -l)
# / var

# \ dir
# current (project) directory
CWD     = $(CURDIR)
# compiled/executable files (target dir)
BIN     = $(CWD)/bin
# documentation & external manuals downloads
DOC     = $(CWD)/doc
# libraries / scripts
LIB     = $(CWD)/lib
# source code (not for all languages, Rust/C included)
SRC     = $(CWD)/src
# temporary/generated files
TMP     = $(CWD)/tmp
# CArgo/Rust compiler binaries
CAR     = $(HOME)/.cargo/bin
# / dir

# \ tool
# http/ftp download tool
CURL    = curl -L -o
# Rust toolchain installer/updater
RUSTUP  = $(CAR)/rustup
# Rust Project Manager (most used)
CARGO   = $(CAR)/cargo
# Rust Compiler
RUSTC   = $(CAR)/rustc
# / tool

# \ src
# scripts (Forth-like)
F += $(shell find lib -type f -regex ".+.f$$")
# C/C++
C += $(shell find src -type f -regex ".+.c(pp)?$$")
# Rust
R += $(shell find src -type f -regex ".+.rs$$")
# all source code included into MERGE (public code)
S += $(F) $(C) $(R) Cargo.toml
# / src

# \ all

# run tests & source code autoformat
.PHONY: all
all: $(R)
	$(CARGO) test && $(CARGO) fmt

# run program in interactive mode (REPL/GUI)
.PHONY: repl
repl: $(R)
	$(CARGO) run $(L)

# / all

# \ doc
doc:
# / doc

# \ install
.PHONY: install update
install: $(OS)_install doc
	$(MAKE)   $(RUSTUP)
	$(MAKE)   update

update: $(OS)_update
	$(RUSTUP) update
	$(CARGO)  update

.PHONY: Linux_install Linux_update apt
Linux_install Linux_update apt:
	sudo apt update
	sudo apt install -u `cat apt.txt apt.dev`

$(RUSTUP):
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# / install

# \ git
MERGE  = Makefile README.md apt.txt apt.dev .gitignore .vscode
MERGE += $(S) bin doc lib src tmp

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout ponymuck -- $(MERGE)

.PHONY: ponymuck
ponymuck:
	git push -v
	git checkout $@
	git pull -v

.PHONY: zip
zip:
	git archive \
		--format zip \
		--output $(TMP)/$(MODULE)_$(BRANCH)_$(NOW)_$(REL).src.zip \
	HEAD
# / git

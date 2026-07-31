# Makefile

HOMEBREW_PREFIX ?= $(shell brew --prefix 2>/dev/null)

.PHONY: all clean flyctl galaxy python test

all: flyctl galaxy

clean:
	$(RM) -r venv

flyctl:
	@command -v flyctl >/dev/null 2>&1 || \
		HOMEBREW_NO_AUTO_UPDATE=1 brew install flyctl

galaxy: python
	venv/bin/ansible-galaxy collection install -r requirements.yml

python: venv
	PYTHONWARNINGS='ignore:DEPRECATION' venv/bin/pip install -r requirements.txt

test: galaxy
	venv/bin/pre-commit run --all-files

venv:
	python3 -m venv --upgrade-deps venv

export HOMEBREW_NO_AUTO_UPDATE ?= 1
export HOMEBREW_NO_ENV_HINTS ?= 1

.PHONY: all clean flyctl galaxy python test

all: flyctl galaxy

clean:
	$(RM) -r venv

flyctl:
	@command -v $@ >/dev/null 2>&1 || \
		brew install --quiet $@

galaxy: python
	venv/bin/ansible-galaxy collection install -r requirements.yml

python: venv
	venv/bin/pip install -r requirements.txt

test: python
	venv/bin/pre-commit run --all-files

venv: .python-version
	$(RM) -r $@
	python$(shell cat .python-version) -m venv $@

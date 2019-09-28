clean_list += $(wildcard *.out)
clean_list += $(wildcard generated/*/*.lua)
clean_list += .venv .dbcache
value_src += $(wildcard pkg/value/*.lua) $(wildcard pkg/common/*.lua)
value_src += $(foreach t,$(wildcard pkg/value/*.lua.yaml),$(t:pkg/%.yaml=generated/%))
segment_src += $(wildcard pkg/segment/*.lua) $(wildcard pkg/common/*.lua)
segment_src += $(foreach t,$(wildcard pkg/segment/*.lua.yaml),$(t:pkg/%.yaml=generated/%))
targets += out/value.lua out/segment.lua

.PHONY: all clean test coverage generate

all: build

build: $(targets)

test:
	busted

clean: $(clean_list)
	@- $(RM) -rf $(clean_list)

coverage: clean
	busted --coverage
	luacov

out/segment.lua: $(segment_src)
	cat $^ > $@

out/value.lua: $(value_src)
	cat $^ > $@

generated/%.lua: pkg/%.lua.yaml
	( . .venv/bin/activate && \
	  wowdb-query -c $< -o $@ $(notdir $@))

.dbcache:
	mkdir .dbcache

.venv:
	( virtualenv .venv && \
	  . .venv/bin/activate && \
	  pip install git+ssh://git@github.com/nan-gameware/nan-wa-utils)

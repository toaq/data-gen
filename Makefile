.ONESHELL:
.SHELLFLAGS = -ce
.PHONY: checkdeps clean redownload

all: checkdeps clean redownload data

checkdeps:
	@curl		--version >/dev/null
	find		--version >/dev/null
	jq			--version >/dev/null
	python3 --version >/dev/null

clean:
	rm -rf data

data: data/toadua $(shell find static/*)
	cp -a static/* data
	touch $@

data/toadua: data/toadua/basic.json data/toadua/dump.json data/toadua/glosses.json
	touch $@

redownload:
	make -B data/toadua/dump.json

data/toadua/dump.json:
	mkdir -p $(shell dirname $@)
	curl https://toadua.uakci.pl/api \
		-X POST -H 'Content-Type: application/json' \
		-d '{"action": "search", "query": ["term", ""]}' \
		-o $@
	jq -e .success $@ >/dev/null || exit 1
	cp $@ $@.temp
	jq .results $@.temp > $@
	rm $@.temp

data/toadua/basic.json: data/toadua/dump.json
	jq -c '
		[ .[]
		| select(.scope == "en"
				 and .score >= 0
				 and (.head | index(" ") | not))
		| {head, body} ]
	' $< > $@

data/toadua/glosses.json: data/toadua/basic.json
	python3 ./scripts/extract-glosses.py < $< > $@

#!/usr/bin/env -S make -f

include *.mk

# ensure this is (re)evaluated last
include config.mk

all: all_json all_html
	rm -f header.*

all_json: $(ENDPOINTS) $(ENDPOINTS:.json=.md) $(ENDPOINTS:.json=.html) $(ENDPOINTS:.json=.txt) $(OID_ENDPOINTS) $(OID_ENDPOINTS:.json=.md) $(OID_ENDPOINTS:.json=.html) $(OID_ENDPOINTS:.json=.txt)
	@echo Generated $^

all_html: $(patsubst %.md,%.html,$(wildcard *.md */*.md */*/*.md)) index.html
	@echo Generated $^

$(OID_ENDPOINTS): %.json : data/quotes-en.json
	jq --raw-output '.[] | select(._id["$$oid"] == "$*") | { text: .text, author: .author }' $< > $@

index.md: README.md
	cp $< $@

qotd.json: data/quotes.json
	jq --raw-output '.[] | { text: .text, author: .author } | tostring' $< | sort --random-sort | tail --lines 1 | jq > $@

random.%: qotd.%
	cp $< $@

$(LANG_ENDPOINTS): %.json: data/quotes-%.json
	jq --raw-output '[ .[] | { text: .text, author: .author } ]' $< > $@

$(ARR_ENDPOINTS:.json=.md): %.md: %.json
	jq --raw-output '. | group_by(.author)[] | { author: .[0].author, quotes: [ .[].text ] } | "## \(.author)\n\n> \(.quotes|join("\n\n> "))\n\n---\n"' $< > $@

$(OBJ_ENDPOINTS:.json=.md): %.md: %.json
	jq --raw-output '"> \(.text)\n\n- \(.author)"' $< > $@

%.html: %.md authors.yaml header.html
	pandoc --quiet --standalone --template=GitHub.html5 --metadata-file=authors.yaml --include-in-header=header.html --from $(PANDOC_FORMAT) --to html --output $@ $<

%.txt: %.html
	pandoc --from html --to plain --wrap=none $< --output $@

.PHONY: all all_json all_html


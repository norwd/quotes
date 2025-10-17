#!/usr/bin/env make

PANDOC_FORMAT := markdown+yaml_metadata_block+backtick_code_blocks+fenced_code_attributes+inline_notes+emoji-implicit_figures+shortcut_reference_links+spaced_reference_links+autolink_bare_uris-citations
LANG_ENDPOINTS := $(patsubst data/quotes-%.json,%.json,$(wildcard data/quotes-*.json))
ARR_ENDPOINTS := $(LANG_ENDPOINTS)
OBJ_ENDPOINTS := qotd.json random.json
ENDPOINTS := $(ARR_ENDPOINTS) $(OBJ_ENDPOINTS)

all: all_json all_html
	rm -f header.*

all_json: $(ENDPOINTS) $(ENDPOINTS:.json=.md) $(ENDPOINTS:.json=.html) $(ENDPOINTS:.json=.txt) json_by_id
	@echo Generated $^

all_html: $(patsubst %.md,%.html,$(wildcard *.md */*.md */*/*.md)) index.html
	@echo Generated $^

json_by_id: data/quotes-en.json
	jq --raw-output '.[] | { id: ._id["$$oid"], text: .text, author: .author } | "echo \"" + @base64 "\({ text: .text, author: .author })" + "\" | base64 --decode | jq > \(.id).json"' $< | sh

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

%.html: %.md
	pandoc --quiet --standalone --template=GitHub.html5 --metadata-file=authors.yaml --include-in-header=header.html --from $(PANDOC_FORMAT) --to html --output $@ $<

%.txt: %.html
	pandoc --from html --to plain --wrap=none $< --output $@

.PHONY: all all_json all_html json_by_id

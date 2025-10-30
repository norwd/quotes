#!/usr/bin/env -S make -f

include *.mk

# ensure this is (re)evaluated last
include config.mk

all: all_json all_html

all_json: $(ENDPOINTS) $(ENDPOINTS:.json=.md) $(ENDPOINTS:.json=.html) $(ENDPOINTS:.json=.txt)

all_html: $(patsubst %.md,%.html,$(wildcard *.md */*.md */*/*.md)) index.html

clean:
	rm -f $(patsubst %.md,%.html,$(wildcard *.md */*.md */*/*.md))
	rm -f $(ENDPOINTS)
	rm -f $(ENDPOINTS:.json=.md)
	rm -f $(ENDPOINTS:.json=.html)
	rm -f $(ENDPOINTS:.json=.txt)
	rm -f authors.txt authors.html authors.md authors.json
	rm -f index.txt index.html index.md
	rm -f authors.yaml

$(OID_ENDPOINTS): %.json : data/quotes.json
	jq --raw-output '.[] | select(._id["$$oid"] == "$*") | { text: .text, author: .author }' $< > $@

$(AUTH_ENDPOINTS): %.json : data/quotes.json
	jq --raw-output '[ .[] | select( ( .author | gsub("\\(.+\\)$$"; "") | gsub("[^a-zA-Z]+"; "_") ) == "$*" ) | { text: .text, author: .author, id: ._id["$$oid"] } ]' $< > $@

index.md: README.md
	cp $< $@

authors.yaml:
	@echo "---" > $@
	@echo "author-meta:" >> $@
	git authors --list | awk '{ print "  - " $$0 }' | tee -a $@
	@echo "..." >> $@

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

authors.json: data/quotes.json
	jq '[ . | group_by(.author)[] | { id: "\( .[0].author | gsub("\\(.+\\)$$"; "") | gsub("[^a-zA-Z]+"; "_") )", author: .[0].author, count: . | length } ]' $< > $@

authors.md: %.md : %.json
	@echo "# Quote Authors" > $@
	jq --raw-output '.[] | "- [Quotes by \(.author)](./\(.id))"' $< >> $@

%.html: %.md authors.yaml src/header.html
	pandoc --quiet --standalone --template=GitHub.html5 --metadata-file=authors.yaml --include-in-header=src/header.html --from $(PANDOC_FORMAT) --to html --output $@ $<

%.txt: %.html
	pandoc --from html --to plain --wrap=none $< --output $@

.PHONY: all all_json all_html clean


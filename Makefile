#!/usr/bin/env -S make -f

include *.mk

# ensure this is (re)evaluated last
include config.mk

all: all_json all_html all_meta

all_json: $(ENDPOINTS)

all_html: $(patsubst %.md,%.html,$(wildcard *.md */*.md */*/*.md)) $(patsubst %.html,%/index.html,$(HTML_ENDPOINTS)) index.html

all_meta: sitemap.txt version.txt robots.txt security.txt

clean:
	rm -f $(patsubst %.md,%.html,$(wildcard *.md */*.md */*/*.md))
	rm -f $(ENDPOINTS)
	rm -f $(ENDPOINTS:.json=.md)
	rm -f $(ENDPOINTS:.json=.html)
	rm -f $(ENDPOINTS:.json=.txt)
	rm -f authors.txt authors.html authors.md authors.json
	rm -f index.txt index.html index.md
	rm -f authors.yaml
	rm -f sitemap.txt

sitemap.txt:
	find . -type f -printf "${BASE_URL}/%P\n" | sed -e 's/\(\.html\)*$//g' | sort --unique | tee $@

version.txt:
	echo "Deployed: $(date --universal +'%FT%TZ')" | tee $@
	echo "Version: v0.1.${FORGEJO_RUN_NUMBER:-0}.$((${FORGEJO_RUN_ATTEMPT:-1} - 1))" | tee -a $@
	echo "Source: ${FORGEJO_SERVER_URL}/${FORGEJO_REPOSITORY}/src/commit/$(echo "${FORGEJO_SHA:-$(git log --pretty=%H --max-count=1)}" | head -c 7)" | tee -a $@

robots.txt:
	echo "# Block AI Crawlers (see: https://github.com/ai-robots-txt)" | tee $@
	curl -sSL --create-dirs --output - https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/refs/heads/main/robots.txt | tee -a $@
	echo "" | tee -a $@
	echo "# List of pages and files" | tee -a $@
	echo "Sitemap: ${BASE_URL}/sitemap.txt" | tee -a $@

security.txt: contact.txt security/policy.txt humans.txt
	echo "Contact: ${BASE_URL}/contact" | tee $@
	echo "Policy: ${BASE_URL}/security/policy" | tee -a $@
	echo "Acknowledgments: ${BASE_URL}/humans" | tee -a $@
	echo "Canonical: ${BASE_URL}/security.txt" | tee -a $@
	echo "Expires: $(date -u +"%Y-12-31T23:59:59.999Z")" | tee -a $@

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
	jq '[ . | group_by(.author)[] | { id: "\( .[0].author | gsub("[^a-zA-Z]+\\(.+\\)$$"; "") | gsub("[^a-zA-Z]+"; "_") )", author: .[0].author, count: . | length } ]' $< > $@

authors.md: %.md : %.json
	@echo "# Quote Authors" > $@
	jq --raw-output '.[] | "- [Quotes by \(.author)](./\(.id))"' $< >> $@

%/index.html: %.md authors.yaml src/header.html
	mkdir -p $(patsubst %/index.html,%,$@)
	pandoc --quiet --standalone --template=GitHub.html5 --metadata-file=authors.yaml --include-in-header=src/header.html --from $(PANDOC_FORMAT) --to html --output $@ $<

%.html: %/index.html
	cp $< $@

%.txt: %.html
	pandoc --from html --to plain --wrap=none $< --output $@

.PHONY: all all_json all_html clean

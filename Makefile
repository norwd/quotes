#!/usr/bin/env -S make -f

include OID_ENDPOINTS.mk
include AUTH_ENDPOINTS.mk
include config.mk # ensure this is (re)evaluated last

all: sitemap.txt

clean:
	rm -f $(patsubst %.md,%.html,$(wildcard *.md */*.md */*/*.md))
	rm -f $(ENDPOINTS)
	rm -f authors.txt authors.html authors.md authors.json
	rm -f index.txt index.html index.md
	rm -f authors.yaml
	rm -f sitemap.txt

sitemap.txt: $(ENDPOINTS)
	find . -type f -printf "$${BASE_URL}/%P\n" | sed -e 's/\(\.html\)*$$//g' | grep -v '/index$$' | grep -v '/\.' | grep -v '.*\.mk' | grep -v 'Makefile' | grep -v '/src/' | sort --unique | tee $@

version.txt:
	echo "Deployed: $$(date --universal +'%FT%TZ')" | tee $@
	echo "Version: v0.1.$${FORGEJO_RUN_NUMBER:-0}.$$(($${FORGEJO_RUN_ATTEMPT:-1} - 1))" | tee -a $@
	echo "Source: $${FORGEJO_SERVER_URL}/$${FORGEJO_REPOSITORY}/src/commit/$$(echo "$${FORGEJO_SHA:-$$(git log --pretty=%H --max-count=1)}" | head -c 7)" | tee -a $@

robots.txt:
	echo "# Block AI Crawlers (see: https://github.com/ai-robots-txt)" > $@
	curl -sSL --fail --output - https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/refs/heads/main/robots.txt | tee -a $@
	echo "" >> $@
	echo "# List of pages and files" >> $@
	echo "Sitemap: $${BASE_URL}/sitemap.txt" >> $@

security.txt: contact.txt security/policy.txt humans.txt
	echo "Contact: $${BASE_URL}/contact" | tee $@
	echo "Policy: $${BASE_URL}/security/policy" | tee -a $@
	echo "Acknowledgments: $${BASE_URL}/humans" | tee -a $@
	echo "Canonical: $${BASE_URL}/security.txt" | tee -a $@
	echo "Expires: $$(date -u +"%Y-12-31T23:59:59.999Z")" | tee -a $@

contact.md: SUPPORT.md
	cp $< $@

code-of-conduct.md: CODE_OF_CONDUCT.md
	cp $< $@

security/policy.md: SECURITY.md
	mkdir -p "$$(dirname $@)"
	cp $< $@

contributing.md: CONTRIBUTING.md
	cp $< $@

humans.md:
	echo "# Humans to Thank" > $@
	echo >> $@
	echo "A huge thanks to all and colaborators who have contributed!" | tee -a $@
	echo >> $@
	echo "## Contributors to [$${FORGEJO_REPOSITORY}]($${FORGEJO_SERVER_URL}/$${FORGEJO_REPOSITORY})" | tee -a $@
	echo >> $@
	git log --pretty='%aN (%aE)' | sort --unique | grep -v '\[bot\]' | awk '{ print "- " $$0 }' | tee -a $@

changelog.md:
	echo "" > $@
	echo "---" >> $@
	echo "lang: en" >> $@
	echo "title: Changelog" >> $@
	echo "..." >> $@
	echo >> $@
	curl -H 'accept: application/json' --fail --output - "$${FORGEJO_SERVER_URL}/api/v1/repos/$${FORGEJO_REPOSITORY}/releases" | jq --raw-output '.[]|"## [\(.name)](\(.html_url))\n\n\(.body)\n"' | tee -a $@

index.md: .forgejo/README.md
	cp $< $@

authors.yaml:
	@echo "---" > $@
	@echo "author-meta:" >> $@
	git log --pretty='%aN' | sort --unique | grep -v '\[bot\]' | awk '{ print "  - " $$0 }' | tee -a $@
	@echo "..." >> $@

qotd.json: data/quotes.json
	jq --raw-output '.[] | { text: .text, author: .author } | tostring' $< | sort --random-sort | tail --lines 1 | jq > $@

random.%: qotd.%
	cp $< $@

authors.json: data/quotes.json
	jq '[ . | group_by(.author)[] | { id: "\( .[0].author | gsub("[^a-zA-Z]+\\(.+\\)$$"; "") | gsub("[^a-zA-Z]+"; "_") )", author: .[0].author, count: . | length } ]' $< > $@

authors.md: %.md : %.json
	@echo "# Quote Authors" > $@
	jq --raw-output '.[] | "- [Quotes by \(.author)](./\(.id))"' $< >> $@

%.txt: %.html
	pandoc --from html --to plain --wrap=none $< --output $@

%.html: %/index.html
	cp $< $@

%/index.html: %.md authors.yaml src/header.html
	mkdir -p $(patsubst %/index.html,%,$@)
	pandoc --quiet --standalone --template=GitHub.html5 --metadata-file=authors.yaml --include-in-header=src/header.html --from $(PANDOC_FORMAT) --to html --output $@ $<

$(OID_ENDPOINTS): %.json : data/quotes.json
	jq --raw-output '.[] | select(._id["$$oid"] == "$*") | { text: .text, author: .author }' $< > $@

$(AUTH_ENDPOINTS): %.json : data/quotes.json
	jq --raw-output '[ .[] | select( ( .author | gsub("\\(.+\\)$$"; "") | gsub("[^a-zA-Z]+"; "_") ) == "$*" ) | { text: .text, author: .author, id: ._id["$$oid"] } ]' $< > $@

$(LANG_ENDPOINTS): %.json: data/quotes-%.json
	jq --raw-output '[ .[] | { text: .text, author: .author } ]' $< > $@

$(ARR_ENDPOINTS:.json=.md): %.md: %.json
	jq --raw-output '. | group_by(.author)[] | { author: .[0].author, quotes: [ .[].text ] } | "## \(.author)\n\n> \(.quotes|join("\n\n> "))\n\n---\n"' $< > $@

$(OBJ_ENDPOINTS:.json=.md): %.md: %.json
	jq --raw-output '"> \(.text)\n\n- \(.author)"' $< > $@

OID_ENDPOINTS.mk: data/quotes.json
	jq --raw-output '.[]._id["$$oid"] | "OID_ENDPOINTS := $$(OID_ENDPOINTS) \(.).json"' $< | tee $@

AUTH_ENDPOINTS.mk: data/quotes.json
	jq --raw-output 'unique_by(.author)[] | "AUTH_ENDPOINTS := $$(AUTH_ENDPOINTS) \( .author | gsub("\\(.+\\)$$"; "") | gsub("[^a-zA-Z]+"; "_") | gsub("_$$"; "") ).json"' $< | tee $@

.PRECIOUS: %.html %/index.html

.PHONY: all clean

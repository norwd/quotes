PANDOC_FORMAT := markdown+yaml_metadata_block+backtick_code_blocks+fenced_code_attributes+inline_notes+emoji-implicit_figures+shortcut_reference_links+spaced_reference_links+autolink_bare_uris-citations
LANG_ENDPOINTS := $(patsubst data/quotes-%.json,%.json,$(wildcard data/quotes-*.json))
ARR_ENDPOINTS := $(AUTH_ENDPOINTS) $(LANG_ENDPOINTS)
OBJ_ENDPOINTS := $(OID_ENDPOINTS) qotd.json random.json
JSON_ENDPOINTS := $(ARR_ENDPOINTS) $(OBJ_ENDPOINTS) authors.json
MARKDOWN_ENDPOINTS := $(JSON_ENDPOINTS:.json=.md) $(wildcard *.md */*.md */*/*.md)
HTML_ENDPOINTS := $(MARKDOWN_ENDPOINTS:.md=.html) $(patsubst %.md,%/index.html,$(MARKDOWN_ENDPOINTS)) index.html
TXT_ENDPOINTS := $(MARKDOWN_ENDPOINTS:.md=.txt)
META_ENDPOINTS := robots.txt security.txt # sitemap.txt version.txt
ENDPOINTS := $(JSON_ENDPOINTS) $(MARKDOWN_ENDPOINTS) $(HTML_ENDPOINTS) $(TXT_ENDPOINTS) $(META_ENDPOINTS)

PANDOC_FORMAT := markdown+yaml_metadata_block+backtick_code_blocks+fenced_code_attributes+inline_notes+emoji-implicit_figures+shortcut_reference_links+spaced_reference_links+autolink_bare_uris-citations
LANG_ENDPOINTS := $(patsubst data/quotes-%.json,%.json,$(wildcard data/quotes-*.json))
ARR_ENDPOINTS := $(AUTH_ENDPOINTS) $(LANG_ENDPOINTS)
OBJ_ENDPOINTS := $(OID_ENDPOINTS) qotd.json random.json
ENDPOINTS := $(ARR_ENDPOINTS) $(OBJ_ENDPOINTS) authors.json


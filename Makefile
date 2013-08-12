MDC = pandoc
MDFLAGS = -f markdown -t html5 -S -s --data-dir=. --template=base
TEMPLATES = templates/base.html5
MD = $(shell find . -name "*.md" -print)
HTML = ${MD:.md=.html}
REMOTEUSER = www-data
REMOTEHOST = justinpoliey.com
REMOTEDIR = /var/www/justinpoliey.com

site: $(HTML)

$(HTML): $(TEMPLATES)

%.html: %.md
	$(MDC) $(MDFLAGS) -o $@ $<

.PHONY: clean serve deploy
clean:
	rm $(HTML)

serve:
	python -m SimpleHTTPServer 8080

deploy:
	rsync                                        \
		--verbose                                \
		--archive                                \
		--compress                               \
		--cvs-exclude                            \
		--exclude-from=.gitignore                \
		.                                        \
		$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)

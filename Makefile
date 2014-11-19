MDFLAGS = -f markdown -t html5 -S --data-dir=.
REMOTEUSER = www-data
REMOTEHOST = justinpoliey.com
REMOTEDIR = /var/www/justinpoliey.com

site: index.html articles

# front page

index.html: index.html.fragment templates/base.html5
	pandoc -t html5 -S --data-dir=. --template=base -o $@ $<

FRAGMENTS = about.html contact.html articles/index.html projects/index.html

.INTERMEDIATE: index.html.fragment
index.html.fragment: $(FRAGMENTS)
	cat $^ > $@

.INTERMEDIATE: $(FRAGMENTS)
$(FRAGMENTS): %.html: %.md templates/fragment.html5
	pandoc -f markdown-citations -t html5 --data-dir=. --template=fragment -o $@ $<

# articles

articles: $(patsubst %.md, %.html, $(wildcard articles/*/index.md))

articles/%.html: articles/%.md templates/article.html5
	pandoc $(MDFLAGS) --template=article -o $@ $<

# catch-all for stray markdowns

%.html: %.md
	pandoc $(MDFLAGS) --template=base -o $@ $<

# maintenance tasks

.PHONY: clean serve deploy

clean:
	-rm index.html
	-rm articles/*/index.html

serve:
	python -m SimpleHTTPServer 8080

deploy:
	rsync --verbose --archive --compress --cvs-exclude --exclude=.git . $(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)

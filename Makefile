#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the Alumni Internet Directory
#      $Id: Makefile,v 3.18 1998/06/10 16:23:41 mradwin Exp mradwin $
#

WWWROOT=/home/web/radwin.org
WWWDIR=$(WWWROOT)/docs/mvhs-alumni
CGIDIR=$(WWWROOT)/cgi-bin
AID_UTIL_PL=$(CGIDIR)/aid_util.pl

RM=/bin/rm -f

ADR_MASTER=./data/master.adr
ADR_ALPHA=./data/alpha.adr
ADR_CLASS=./data/class.adr
ADR_AWALT=./data/awalt.adr
ADR_DATE=./data/date.adr

BIN_MULTI=./bin/aid_multi_alpha_html
BIN_ALPHA=./bin/aid_alpha_html
BIN_BOOK=./bin/aid_book
BIN_CLASS=./bin/aid_class_html
BIN_GONERS=./bin/aid_goners_html
BIN_HOME=./bin/aid_home_html
BIN_RECENT=./bin/aid_recent_html
BIN_VERBOSE=./bin/aid_verbose_html
BIN_WWW=./bin/aid_www_html

TARFILES=README \
	Makefile \
	cgi-bin/*.pl \
	cgi-bin/mvhsaid \
	bin/aid_* \
	data/*.include

SNAPSHOTFILES=mvhs \
	web/images/vcard.gif \
	web/mvhs-alumni/*.gif \
	web/mvhs-alumni/whatsnew

all:	adrfile index submit reunions links tech copyright \
	recent pages multi class awalt goners \
	verbose books

ADRFILE=$(WWWDIR)/master.adr
adrfile:	$(ADRFILE)
$(ADRFILE):	$(ADR_MASTER)
	cp $(ADR_MASTER) $(WWWDIR)

ALPHA=$(WWWDIR)/all.html
alpha:	$(ALPHA)
$(ALPHA):	$(ADR_ALPHA) $(BIN_ALPHA)
	$(BIN_ALPHA) $(ADR_ALPHA) $(ALPHA)

MULTI=$(WWWDIR)/alpha/a-index.html
multi:	$(MULTI)
$(MULTI):	$(ADR_ALPHA) $(BIN_MULTI)
	$(BIN_MULTI) $(ADR_ALPHA)

CLASS=$(WWWDIR)/class.html
class:	$(CLASS)
$(CLASS):	$(ADR_CLASS) $(BIN_CLASS)
	$(BIN_CLASS) $(ADR_CLASS) $(CLASS)

AWALT=$(WWWDIR)/awalt.html
awalt:	$(AWALT)
$(AWALT):	$(ADR_AWALT) $(BIN_CLASS)
	$(BIN_CLASS) -a $(ADR_AWALT) $(AWALT)

RECENT=$(WWWDIR)/recent.html
recent:	$(RECENT)
$(RECENT):	$(ADR_DATE) $(BIN_RECENT)
	$(BIN_RECENT) $(ADR_DATE) $(RECENT)

GONERS=$(WWWDIR)/invalid.html
goners:	$(GONERS)
$(GONERS):	$(ADR_ALPHA) $(BIN_GONERS)
	$(BIN_GONERS) $(ADR_ALPHA) $(GONERS)

PAGES=$(WWWDIR)/pages.html
pages:	$(PAGES)
$(PAGES):	$(ADR_ALPHA) $(BIN_WWW)
	$(BIN_WWW) $(ADR_ALPHA) $(PAGES)

VERBOSE=$(WWWDIR)/class/index.html
verbose:	$(VERBOSE)
$(VERBOSE):	$(ADR_CLASS) $(BIN_VERBOSE)
	mkdir -p $(WWWDIR)/class
	$(BIN_VERBOSE) $(ADR_CLASS)

INDEX=$(WWWDIR)/index.html
index:	$(INDEX)
$(INDEX):	data/index.include $(BIN_HOME) $(AID_UTIL_PL) $(ADR_MASTER)
	$(BIN_HOME) -p0 -i data/index.include \
		-t 'Welcome to the MVHS Alumni Internet Directory!' \
		$(INDEX)

REUNIONS=$(WWWDIR)/reunions.html
reunions:	$(REUNIONS)
$(REUNIONS):	data/reunions.include $(BIN_HOME)
	$(BIN_HOME) -p11 -i data/reunions.include \
		-t 'Reunions: when, where, who to contact' \
		$(REUNIONS)

LINKS=$(WWWDIR)/links.html
links:	$(LINKS)
$(LINKS):	data/links.include $(BIN_HOME)
	$(BIN_HOME) -p12 -i data/links.include \
		-t 'Links: other MVHS and Awalt websites' \
		$(LINKS)

NICKNAMES=$(WWWDIR)/books/index.html
nicknames:	$(NICKNAMES)
$(NICKNAMES):	data/nicknames.include $(BIN_HOME)
	mkdir -p $(WWWDIR)/books
	$(BIN_HOME) -p13 -i data/nicknames.include \
		-t 'Nicknames: address books for your e-mail program' \
		$(NICKNAMES)

TECH=$(WWWDIR)/tech.html
tech:	$(TECH)
$(TECH):	data/tech.include $(BIN_HOME)
	$(BIN_HOME) -p14 -i data/tech.include \
		-t 'Tech Notes: info about the Directory' \
		$(TECH)

COPYRIGHT=$(WWWDIR)/copyright.html
copyright:	$(COPYRIGHT)
$(COPYRIGHT):	data/copyright.include $(BIN_HOME)
	$(BIN_HOME) -p15 -i data/copyright.include \
		-t 'Acceptable Use and Copyright' \
		$(COPYRIGHT)

SUBMIT=$(WWWDIR)/add.html
submit:	$(SUBMIT)
$(SUBMIT):	$(BIN_HOME) $(AID_UTIL_PL)
	$(BIN_HOME) -s -p10 \
		-t 'Add an Entry to the Directory' \
		$(SUBMIT)

BOOKS=$(WWWDIR)/books/mvhs.vcf
books:	$(BOOKS)
$(BOOKS):	$(ADR_ALPHA) $(BIN_BOOK)
	mkdir -p $(WWWDIR)/books
	$(BIN_BOOK) \
		-p $(WWWDIR)/books/pine.txt \
		-e $(WWWDIR)/books/elm.txt \
		-b $(WWWDIR)/books/berkeley.txt \
		-w $(WWWDIR)/books/eudora2.txt \
		-m $(WWWDIR)/books/eudora3.txt \
		-n $(WWWDIR)/books/address-book.html \
		-l $(WWWDIR)/books/address-book.ldif \
		-v $(WWWDIR)/books/mvhs.vcf \
		$(ADR_ALPHA)
	$(RM) $(WWWDIR)/books/pine.txt.lu

$(ADR_ALPHA):	$(ADR_MASTER)
	sort -f -t\; +2 -5 $(ADR_MASTER) > $(ADR_ALPHA)

$(ADR_CLASS):	$(ADR_MASTER)
	sort -f -t\; +12 -13 +2 -5 $(ADR_MASTER) > $(ADR_CLASS)

$(ADR_AWALT):	$(ADR_CLASS)
	grep -i awalt $(ADR_CLASS) > $(ADR_AWALT)

$(ADR_DATE):	$(ADR_MASTER)
	sort -f -t\; +9 -10 $(ADR_MASTER) > $(ADR_DATE)

alpha.txt:	$(ADR_ALPHA) $(BIN_ALPHA)
	$(BIN_ALPHA) -t $(ADR_ALPHA) alpha.txt

class.txt:	$(ADR_CLASS) $(BIN_CLASS)
	$(BIN_CLASS) -t $(ADR_CLASS) class.txt

tar:
	tar cf $(WWWDIR)/mvhsaid.tar $(TARFILES)
	gzip -f $(WWWDIR)/mvhsaid.tar

snapshot:
	( cd $(HOME) ; tar cf $(WWWDIR)/snapshot.tar $(SNAPSHOTFILES) )
	gzip -f $(WWWDIR)/snapshot.tar

chmod:
	( cd $(WWWDIR) ; chmod -R a+rX * )

clean:
	$(RM) TAGS class.txt alpha.txt $(ADR_CLASS) $(ADR_ALPHA)
	$(RM) $(ADR_DATE) $(ADR_AWALT)

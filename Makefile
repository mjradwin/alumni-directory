#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the Alumni Internet Directory
#      $Id: Makefile,v 3.32 1998/10/26 22:50:55 mradwin Exp mradwin $
#

WWWROOT=/home/web/radwin.org
WWWDIR=$(WWWROOT)/docs/mvhs-alumni
CGIDIR=$(WWWROOT)/cgi-bin
AID_UTIL_PL=$(CGIDIR)/aid_util.pl
MVHSDIR=/home/users/mradwin/mvhs

RM=/bin/rm -f

ADR_MASTER=$(MVHSDIR)/data/master.adr
ADR_ALPHA=$(MVHSDIR)/data/alpha.adr
ADR_CLASS=$(MVHSDIR)/data/class.adr
ADR_AWALT=$(MVHSDIR)/data/awalt.adr
ADR_DATE=$(MVHSDIR)/data/date.adr

BIN_MULTI_ALPHA=$(MVHSDIR)/bin/aid_multi_alpha_html
BIN_ALPHA=$(MVHSDIR)/bin/aid_alpha_html
BIN_BOOK=$(MVHSDIR)/bin/aid_book
BIN_CLASS=$(MVHSDIR)/bin/aid_class_html
BIN_GONERS=$(MVHSDIR)/bin/aid_goners_html
BIN_HOME=$(MVHSDIR)/bin/aid_home_html
BIN_RECENT=$(MVHSDIR)/bin/aid_shortlist_html
BIN_MULTI_CLASS=$(MVHSDIR)/bin/aid_multi_class_html
BIN_PAGES=$(MVHSDIR)/bin/aid_shortlist_html

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

all:	adrfile index submit addupdate reunions links faq copyright \
	recent pages multi_alpha class awalt goners \
	multi_class books

ADRFILE=$(WWWDIR)/master.adr
adrfile:	$(ADRFILE)
$(ADRFILE):	$(ADR_MASTER)
	cp $(ADR_MASTER) $(WWWDIR)

MULTI_ALPHA=$(WWWDIR)/alpha/a-index.html
multi_alpha:	$(MULTI_ALPHA)
$(MULTI_ALPHA):	$(ADR_ALPHA) $(BIN_MULTI_ALPHA)
	$(BIN_MULTI_ALPHA) $(ADR_ALPHA)

CLASS=$(WWWDIR)/class/all.html
class:	$(CLASS)
$(CLASS):	$(ADR_CLASS) $(BIN_CLASS)
	mkdir -p $(WWWDIR)/class
	$(BIN_CLASS) $(ADR_CLASS) $(CLASS)

AWALT=$(WWWDIR)/class/awalt.html
awalt:	$(AWALT)
$(AWALT):	$(ADR_AWALT) $(BIN_CLASS)
	mkdir -p $(WWWDIR)/class
	$(BIN_CLASS) -a $(ADR_AWALT) $(AWALT)

RECENT=$(WWWDIR)/recent.html
recent:	$(RECENT)
$(RECENT):	$(ADR_CLASS) $(BIN_RECENT)
	$(BIN_RECENT) -v -m1 $(ADR_CLASS) $(RECENT)

GONERS=$(WWWDIR)/invalid.html
goners:	$(GONERS)
$(GONERS):	$(ADR_ALPHA) $(BIN_GONERS)
	$(BIN_GONERS) $(ADR_ALPHA) $(GONERS)

PAGES=$(WWWDIR)/pages.html
pages:	$(PAGES)
$(PAGES):	$(ADR_CLASS) $(BIN_PAGES)
	$(BIN_PAGES) -w $(ADR_CLASS) $(PAGES)

MULTI_CLASS=$(WWWDIR)/class/index.html
multi_class:	$(MULTI_CLASS)
$(MULTI_CLASS):	$(ADR_CLASS) $(BIN_MULTI_CLASS)
	mkdir -p $(WWWDIR)/class
	$(BIN_MULTI_CLASS) $(ADR_CLASS)

INDEX=$(WWWDIR)/index.html
index:	$(INDEX)
$(INDEX):	$(MVHSDIR)/data/index.include $(BIN_HOME) $(AID_UTIL_PL) \
		$(ADR_MASTER)
	$(BIN_HOME) -p0 -i $(MVHSDIR)/data/index.include \
		-t 'Welcome to the MVHS Alumni Internet Directory!' \
		$(INDEX)

REUNIONS=$(WWWDIR)/etc/reunions.html
reunions:	$(REUNIONS)
$(REUNIONS):	$(MVHSDIR)/data/reunions.include $(BIN_HOME)
	$(BIN_HOME) -p11 -i $(MVHSDIR)/data/reunions.include \
		-t 'Reunions' \
		$(REUNIONS)

LINKS=$(WWWDIR)/etc/links.html
links:	$(LINKS)
$(LINKS):	$(MVHSDIR)/data/links.include $(BIN_HOME)
	$(BIN_HOME) -p12 -i $(MVHSDIR)/data/links.include \
		-t 'Other MVHS and Awalt websites' \
		$(LINKS)

NICKNAMES=$(WWWDIR)/books/HEADER.html
nicknames:	$(NICKNAMES)
$(NICKNAMES):	$(MVHSDIR)/data/nicknames.include $(BIN_HOME)
	mkdir -p $(WWWDIR)/books
	$(BIN_HOME) -p13 -i $(MVHSDIR)/data/nicknames.include \
		-t 'Download Nickname and Address Book files' \
		$(NICKNAMES)

FAQ=$(WWWDIR)/etc/faq.html
faq:	$(FAQ)
$(FAQ):	$(MVHSDIR)/data/faq.include $(BIN_HOME)
	$(BIN_HOME) -p14 -i $(MVHSDIR)/data/faq.include \
		-t 'Frequently Asked Questions' \
		$(FAQ)

COPYRIGHT=$(WWWDIR)/etc/copyright.html
copyright:	$(COPYRIGHT)
$(COPYRIGHT):	$(MVHSDIR)/data/copyright.include $(BIN_HOME)
	$(BIN_HOME) -p15 -i $(MVHSDIR)/data/copyright.include \
		-t 'Acceptable Use and Copyright' \
		$(COPYRIGHT)

SUBMIT=$(WWWDIR)/add/new.html
submit:	$(SUBMIT)
$(SUBMIT):	$(BIN_HOME) $(AID_UTIL_PL)
	$(BIN_HOME) -s -p20 \
		-t 'Add an Entry to the Directory' \
		$(SUBMIT)

ADDUPDATE=$(WWWDIR)/add/index.html
addupdate:	$(ADDUPDATE)
$(ADDUPDATE):	$(MVHSDIR)/data/add.include $(BIN_HOME)
	$(BIN_HOME) -p10 -i $(MVHSDIR)/data/add.include \
		-t 'Add or Update an entry' \
		$(ADDUPDATE)

BOOKS=$(WWWDIR)/books/mvhs.vdir
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
		-v $(BOOKS) \
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

recent.txt:	$(ADR_CLASS) $(BIN_RECENT)
	$(BIN_RECENT) -m3 -t $(ADR_CLASS) recent.txt

tar:
	( cd $(MVHSDIR) ; tar cf $(WWWDIR)/etc/mvhsaid.tar $(TARFILES) )
	gzip -f $(WWWDIR)/etc/mvhsaid.tar

snapshot:
	( cd $(HOME) ; tar cf $(WWWDIR)/etc/snapshot.tar $(SNAPSHOTFILES) )
	gzip -f $(WWWDIR)/etc/snapshot.tar

chmod:
	( cd $(WWWDIR) ; chmod -R a+rX * )

clean:
	$(RM) TAGS class.txt alpha.txt $(ADR_CLASS) $(ADR_ALPHA)
	$(RM) $(ADR_DATE) $(ADR_AWALT)

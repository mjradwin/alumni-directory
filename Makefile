#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the Alumni Internet Directory
#      $Id: Makefile,v 3.67 1999/03/05 01:05:30 mradwin Exp mradwin $
#

WWWROOT=/home/web/radwin.org
WWWDIR=$(WWWROOT)/docs/mvhs-alumni
CGIDIR=$(WWWROOT)/cgi-bin
AID_UTIL_PL=$(CGIDIR)/aid_util.pl
MVHSDIR=/home/users/mradwin/mvhs

RM=/bin/rm -f
MV=/bin/mv -f
CP=/bin/cp -pf

ADR_MASTER=$(MVHSDIR)/data/master.adr

BIN_MULTI_ALPHA=$(MVHSDIR)/bin/aid_multi_alpha_html
BIN_ALPHA=$(MVHSDIR)/bin/aid_alpha_html
BIN_BOOK=$(MVHSDIR)/bin/aid_book
BIN_CLASS=$(MVHSDIR)/bin/aid_class_html
BIN_GONERS=$(MVHSDIR)/bin/aid_goners_html
BIN_HOME=$(MVHSDIR)/bin/aid_home_html
BIN_RECENT=$(MVHSDIR)/bin/aid_shortlist_html
BIN_MULTI_CLASS=$(MVHSDIR)/bin/aid_multi_class_html
BIN_PAGES=$(MVHSDIR)/bin/aid_class_html
BIN_STATS=$(MVHSDIR)/bin/aid_stats
BIN_DBM_WRITE=$(MVHSDIR)/bin/aid_dbm_write
BIN_VCARD=$(MVHSDIR)/bin/aid_write_vcards

TARFILES= \
	mvhs/README \
	mvhs/Makefile \
	mvhs/cgi-bin/*.pl \
	mvhs/cgi-bin/mvhsaid \
	mvhs/cgi-bin/nph-aid-search \
	mvhs/cgi-bin/nph-vcard \
	mvhs/bin/aid_* \
	mvhs/data/test.adr \
	mvhs/data/*.include \
	web/images/vcard.gif \
	web/mvhs-alumni/default.css \
	web/mvhs-alumni/*.gif

SNAPSHOTFILES= \
	mvhs \
	mvhs/cgi-bin/RCS/* \
	mvhs/cgi-bin/*.pl \
	mvhs/cgi-bin/mvhsaid \
	mvhs/cgi-bin/nph-aid-search \
	mvhs/cgi-bin/nph-vcard \
	web/images/vcard.gif \
	web/mvhs-alumni/default.css \
	web/mvhs-alumni/*.gif \
	web/mvhs-alumni/master.db

all:	index submit \
	addupdate reunions links faq copyright \
	recent multi_class multi_alpha \
	pages class awalt goners download \
	stats $(CGIDIR)/nph-mvhsaid \
	vcard pine_book

$(CGIDIR)/nph-mvhsaid: $(CGIDIR)/mvhsaid
	$(CP) $(CGIDIR)/mvhsaid $(CGIDIR)/nph-mvhsaid

DBFILE=$(WWWDIR)/master.db
$(DBFILE):	$(ADR_MASTER) $(BIN_DBM_WRITE) $(AID_UTIL_PL)
	$(RM) ./master.db
	$(BIN_DBM_WRITE) $(ADR_MASTER) ./master.db
	$(RM) $(DBFILE)
	$(MV) ./master.db $(DBFILE)
	chmod 0444 $(DBFILE)

VCARD_TS=$(WWWDIR)/vcard/.created
vcard:	$(VCARD_TS)
$(VCARD_TS):	$(DBFILE) $(BIN_VCARD)
	mkdir -p $(WWWDIR)/vcard
	$(BIN_VCARD) $(DBFILE) $(WWWDIR)/vcard

MULTI_ALPHA=$(WWWDIR)/alpha/a-index.html
MULTI_ALPHA_TS=$(WWWDIR)/alpha/.z-index.html
multi_alpha:	$(MULTI_ALPHA_TS)
$(MULTI_ALPHA_TS):	$(DBFILE) $(BIN_MULTI_ALPHA)
	mkdir -p $(WWWDIR)/alpha
	$(BIN_MULTI_ALPHA) $(DBFILE)

CLASS=$(WWWDIR)/class/all.html
CLASS_TS=$(WWWDIR)/class/.all.html
class:	$(CLASS_TS)
$(CLASS_TS):	$(DBFILE) $(BIN_CLASS)
	mkdir -p $(WWWDIR)/class
	$(BIN_CLASS) $(DBFILE) $(CLASS)

AWALT=$(WWWDIR)/class/awalt.html
AWALT_TS=$(WWWDIR)/class/.awalt.html
awalt:	$(AWALT_TS)
$(AWALT_TS):	$(DBFILE) $(BIN_CLASS)
	mkdir -p $(WWWDIR)/class
	$(BIN_CLASS) -a $(DBFILE) $(AWALT)

RECENT=$(WWWDIR)/recent.html
RECENT_TS=$(WWWDIR)/.recent.html
recent:	$(RECENT_TS)
$(RECENT_TS):	$(DBFILE) $(BIN_RECENT)
	$(BIN_RECENT) -v -m 0.5 -M 'two weeks' $(DBFILE) $(RECENT)

GONERS=$(WWWDIR)/invalid.html
GONERS_TS=$(WWWDIR)/.invalid.html
goners:	$(GONERS_TS)
$(GONERS_TS):	$(DBFILE) $(BIN_GONERS)
	$(BIN_GONERS) $(DBFILE) $(GONERS)

PAGES=$(WWWDIR)/pages.html
PAGES_TS=$(WWWDIR)/.pages.html
pages:	$(PAGES_TS)
$(PAGES_TS):	$(DBFILE) $(BIN_PAGES)
	$(BIN_PAGES) -w $(DBFILE) $(PAGES)

MULTI_CLASS=$(WWWDIR)/class/.index.html
multi_class:	$(MULTI_CLASS)
$(MULTI_CLASS):	$(DBFILE) $(BIN_MULTI_CLASS)
	mkdir -p $(WWWDIR)/class
	$(BIN_MULTI_CLASS) $(DBFILE)

INDEX=$(WWWDIR)/index.html
INDEX_TS=$(WWWDIR)/.index.html
index:	$(INDEX_TS)
$(INDEX_TS):	$(MVHSDIR)/data/index.include $(BIN_HOME) $(DBFILE)
	$(BIN_HOME) -p0 -i $(MVHSDIR)/data/index.include \
		-t '' \
		$(INDEX)

REUNIONS=$(WWWDIR)/etc/reunions.html
REUNIONS_TS=$(WWWDIR)/etc/.reunions.html
reunions:	$(REUNIONS_TS)
$(REUNIONS_TS):	$(MVHSDIR)/data/reunions.include $(BIN_HOME)
	$(BIN_HOME) -p11 -i $(MVHSDIR)/data/reunions.include \
		-t 'Reunions' \
		$(REUNIONS)

LINKS=$(WWWDIR)/etc/links.html
LINKS_TS=$(WWWDIR)/etc/.links.html
links:	$(LINKS_TS)
$(LINKS_TS):	$(MVHSDIR)/data/links.include $(BIN_HOME)
	$(BIN_HOME) -p12 -i $(MVHSDIR)/data/links.include \
		-t 'Other MVHS and Awalt Web Resources' \
		$(LINKS)

FAQ=$(WWWDIR)/etc/faq.html
FAQ_TS=$(WWWDIR)/etc/.faq.html
faq:	$(FAQ_TS)
$(FAQ_TS):	$(MVHSDIR)/data/faq.include $(BIN_HOME)
	$(BIN_HOME) -p14 -i $(MVHSDIR)/data/faq.include \
		-t 'Frequently Asked Questions' \
		$(FAQ)

COPYRIGHT=$(WWWDIR)/etc/copyright.html
COPYRIGHT_TS=$(WWWDIR)/etc/.copyright.html
copyright:	$(COPYRIGHT_TS)
$(COPYRIGHT_TS):	$(MVHSDIR)/data/copyright.include $(BIN_HOME)
	$(BIN_HOME) -p16 -i $(MVHSDIR)/data/copyright.include \
		-t 'Acceptable Use - Privacy Statement - Copyright' \
		$(COPYRIGHT)

STATS=$(WWWDIR)/etc/stats.txt
stats:	$(STATS)
$(STATS):	$(BIN_STATS) $(DBFILE)
	$(BIN_STATS) $(DBFILE) $(STATS)

SUBMIT=$(WWWDIR)/add/new.html
SUBMIT_TS=$(WWWDIR)/add/.new.html
submit:	$(SUBMIT_TS)
$(SUBMIT_TS):	$(BIN_HOME) $(AID_UTIL_PL)
	$(BIN_HOME) -s -p20 \
		-t 'Add Your Listing to the Directory' \
		$(SUBMIT)

ADDUPDATE=$(WWWDIR)/add/index.html
ADDUPDATE_TS=$(WWWDIR)/add/.index.html
addupdate:	$(ADDUPDATE_TS)
$(ADDUPDATE_TS):	$(MVHSDIR)/data/add.include $(BIN_HOME)
	$(BIN_HOME) -p10 -i $(MVHSDIR)/data/add.include \
		-t 'Add or Update Your Listing' \
		$(ADDUPDATE)

DOWNLOAD=$(WWWDIR)/download/index.html
DOWNLOAD_TS=$(WWWDIR)/download/.index.html
download:	$(DOWNLOAD_TS)
$(DOWNLOAD_TS):	$(BIN_HOME) $(AID_UTIL_PL) $(DBFILE)
	mkdir -p $(WWWDIR)/download
	$(BIN_HOME) -d -p13 \
		-t 'Download Nickname and Address Book Files' \
		$(DOWNLOAD)

BOOKS=$(WWWDIR)/books/mvhs.vdir
books:	$(BOOKS)
$(BOOKS):	$(DBFILE) $(BIN_BOOK)
	mkdir -p $(WWWDIR)/books
	$(BIN_BOOK) \
		-p $(WWWDIR)/books/pine.txt \
		-e $(WWWDIR)/books/elm.txt \
		-b $(WWWDIR)/books/berkeley.txt \
		-w $(WWWDIR)/books/eudora2.txt \
		-m $(WWWDIR)/books/eudora3.txt \
		-n $(WWWDIR)/books/address-book.html \
		-l $(WWWDIR)/books/address-book.ldif \
		-o $(WWWDIR)/books/outlook.csv \
		-v $(BOOKS) \
		$(DBFILE)
	$(RM) $(WWWDIR)/books/pine.txt.lu

PINE_BOOK=$(HOME)/.addressbook-mvhs
pine_book:	$(PINE_BOOK)
$(PINE_BOOK):	$(DBFILE) $(BIN_BOOK)
	$(BIN_BOOK) -p $(PINE_BOOK) $(DBFILE)
	$(RM) $(PINE_BOOK).lu

alpha.txt:	$(DBFILE) $(BIN_ALPHA)
	$(BIN_ALPHA) -t $(DBFILE) alpha.txt

class.txt:	$(DBFILE) $(BIN_CLASS)
	$(BIN_CLASS) -t $(DBFILE) class.txt

recent.txt:	$(DBFILE) $(BIN_RECENT)
	$(BIN_RECENT) -m3 -t $(DBFILE) recent.txt

tar:
	( cd $(MVHSDIR)/.. ; tar cfz $(WWWDIR)/etc/mvhsaid.tar.gz $(TARFILES) )

snapshot:
	( cd $(HOME) ; tar cfz $(WWWDIR)/etc/snapshot.tar.gz $(SNAPSHOTFILES) )

chmod:
	( cd $(WWWDIR) ; chmod -R a+rX * )

clean:
	$(RM) TAGS class.txt alpha.txt recent.txt

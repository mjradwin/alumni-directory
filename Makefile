#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the Alumni Internet Directory
#      $Id: Makefile,v 3.79 1999/05/03 23:53:47 mradwin Exp mradwin $
#
#   Copyright (c) 1995-1999  Michael John Radwin
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

WWWROOT=/home/web/radwin.org
WWWDIR=$(WWWROOT)/docs/mvhs-alumni
CGIDIR=$(WWWROOT)/cgi-bin
AID_UTIL_PL=$(CGIDIR)/aid_util.pl
AID_SUBMIT_PL=$(CGIDIR)/aid_submit.pl
AIDDIR=/home/users/mradwin/mvhs
TAR_AIDDIR=mvhs
TAR_IMGDIR=web/images
TAR_WWWDIR=web/mvhs-alumni

RM=/bin/rm -f
MV=/bin/mv -f
CP=/bin/cp -pf

ADR_MASTER=$(AIDDIR)/data/master.adr

BIN_MULTI_ALPHA=$(AIDDIR)/bin/aid_multi_alpha_html
BIN_ALPHA=$(AIDDIR)/bin/aid_alpha_html
BIN_BOOK=$(AIDDIR)/bin/aid_book
BIN_CLASS=$(AIDDIR)/bin/aid_class_html
BIN_GONERS=$(AIDDIR)/bin/aid_goners_html
BIN_HOME=$(AIDDIR)/bin/aid_home_html
BIN_RECENT=$(AIDDIR)/bin/aid_shortlist_html
BIN_MULTI_CLASS=$(AIDDIR)/bin/aid_multi_class_html
BIN_PAGES=$(AIDDIR)/bin/aid_class_html
BIN_STATS=$(AIDDIR)/bin/aid_stats
BIN_DBM_WRITE=$(AIDDIR)/bin/aid_dbm_write
BIN_VCARD=$(AIDDIR)/bin/aid_write_vcards

TARFILES= \
	$(TAR_AIDDIR)/README \
	$(TAR_AIDDIR)/COPYING \
	$(TAR_AIDDIR)/Makefile \
	$(TAR_AIDDIR)/cgi-bin/*.pl \
	$(TAR_AIDDIR)/cgi-bin/mvhsaid \
	$(TAR_AIDDIR)/cgi-bin/nph-aid-search \
	$(TAR_AIDDIR)/cgi-bin/nph-vcard \
	$(TAR_AIDDIR)/bin/aid_* \
	$(TAR_AIDDIR)/data/test.adr \
	$(TAR_AIDDIR)/data/*.include \
	$(TAR_WWWDIR)/default.css

SNAPSHOTFILES= \
	$(TAR_AIDDIR) \
	$(TAR_AIDDIR)/cgi-bin/RCS/* \
	$(TAR_AIDDIR)/cgi-bin/*.pl \
	$(TAR_AIDDIR)/cgi-bin/mvhsaid \
	$(TAR_AIDDIR)/cgi-bin/nph-aid-search \
	$(TAR_AIDDIR)/cgi-bin/nph-vcard \
	$(TAR_WWWDIR)/default.css \
	$(TAR_WWWDIR)/.htaccess \
	$(TAR_WWWDIR)/master.db

all:	index submit \
	addupdate reunions links faq copyright \
	recent multi_class multi_alpha \
	pages awalt goners download \
	stats $(CGIDIR)/nph-mvhsaid \
	vcard pine_book

$(CGIDIR)/nph-mvhsaid: $(CGIDIR)/mvhsaid
	$(CP) $(CGIDIR)/mvhsaid $(CGIDIR)/nph-mvhsaid

DBFILE=$(WWWDIR)/master.db
dbfile:	$(DBFILE)
$(DBFILE):	$(ADR_MASTER) $(BIN_DBM_WRITE) $(AID_UTIL_PL)
	$(RM) ./master.db
	$(BIN_DBM_WRITE) $(ADR_MASTER) ./master.db
	$(RM) $(DBFILE)
	$(MV) ./master.db $(DBFILE)
	chmod 0444 $(DBFILE)
	$(AIDDIR)/bin/aid_dbm_read -u ./data/master.u $(DBFILE)

VCARD_TS=$(WWWDIR)/vcard/.created
vcard:	$(VCARD_TS)
$(VCARD_TS):	$(DBFILE) $(BIN_VCARD)
	mkdir -p $(WWWDIR)/vcard
	$(BIN_VCARD) $(DBFILE) $(WWWDIR)/vcard $(MOD_IDS)

MULTI_ALPHA=$(WWWDIR)/alpha/a-index.html
MULTI_ALPHA_TS=$(WWWDIR)/alpha/.z-index.html
multi_alpha:	$(MULTI_ALPHA_TS)
$(MULTI_ALPHA_TS):	$(DBFILE) $(BIN_MULTI_ALPHA)
	mkdir -p $(WWWDIR)/alpha
	$(BIN_MULTI_ALPHA) $(DBFILE)

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
$(INDEX_TS):	$(AIDDIR)/data/index.include $(BIN_HOME) $(DBFILE)
	$(BIN_HOME) -p0 -i $(AIDDIR)/data/index.include \
		-t '' \
		$(INDEX)

REUNIONS=$(WWWDIR)/etc/reunions.html
REUNIONS_TS=$(WWWDIR)/etc/.reunions.html
reunions:	$(REUNIONS_TS)
$(REUNIONS_TS):	$(AIDDIR)/data/reunions.include $(BIN_HOME)
	mkdir -p $(WWWDIR)/etc
	$(BIN_HOME) -p11 -i $(AIDDIR)/data/reunions.include \
		-t 'Reunion Information' \
		$(REUNIONS)

LINKS=$(WWWDIR)/etc/links.html
LINKS_TS=$(WWWDIR)/etc/.links.html
links:	$(LINKS_TS)
$(LINKS_TS):	$(AIDDIR)/data/links.include $(BIN_HOME)
	mkdir -p $(WWWDIR)/etc
	$(BIN_HOME) -p12 -i $(AIDDIR)/data/links.include \
		-t 'Other MVHS and Awalt Resources' \
		$(LINKS)

FAQ=$(WWWDIR)/etc/faq.html
FAQ_TS=$(WWWDIR)/etc/.faq.html
faq:	$(FAQ_TS)
$(FAQ_TS):	$(AIDDIR)/data/faq.include $(BIN_HOME)
	mkdir -p $(WWWDIR)/etc
	$(BIN_HOME) -p14 -i $(AIDDIR)/data/faq.include \
		-t 'Frequently Asked Questions' \
		$(FAQ)

COPYRIGHT=$(WWWDIR)/etc/copyright.html
COPYRIGHT_TS=$(WWWDIR)/etc/.copyright.html
copyright:	$(COPYRIGHT_TS)
$(COPYRIGHT_TS):	$(AIDDIR)/data/copyright.include $(BIN_HOME)
	mkdir -p $(WWWDIR)/etc
	$(BIN_HOME) -p16 -i $(AIDDIR)/data/copyright.include \
		-t 'Acceptable Use, Privacy Statement, Copyright' \
		$(COPYRIGHT)

STATS=$(WWWDIR)/etc/stats.html
stats:	$(STATS)
$(STATS):	$(BIN_STATS) $(DBFILE)
	mkdir -p $(WWWDIR)/etc
	$(BIN_STATS) $(DBFILE) $(STATS)

SUBMIT=$(WWWDIR)/add/new.html
SUBMIT_TS=$(WWWDIR)/add/.new.html
submit:	$(SUBMIT_TS)
$(SUBMIT_TS):	$(BIN_HOME) $(AID_SUBMIT_PL)
	mkdir -p $(WWWDIR)/add
	$(BIN_HOME) -s -p20 \
		-t 'Add Your Listing to the Directory' \
		$(SUBMIT)

ADDUPDATE=$(WWWDIR)/add/index.html
ADDUPDATE_TS=$(WWWDIR)/add/.index.html
addupdate:	$(ADDUPDATE_TS)
$(ADDUPDATE_TS):	$(AIDDIR)/data/add.include $(BIN_HOME)
	mkdir -p $(WWWDIR)/add
	$(BIN_HOME) -p10 -i $(AIDDIR)/data/add.include \
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
	mkdir -p $(WWWDIR)/etc
	( cd $(HOME) ; tar cfz $(WWWDIR)/etc/mvhsaid.tar.gz $(TARFILES) )

snapshot:
	mkdir -p $(WWWDIR)/etc
	( cd $(HOME) ; tar cfz $(WWWDIR)/etc/snapshot.tar.gz $(SNAPSHOTFILES) )

chmod:
	( cd $(WWWDIR) ; chmod -R a+rX * )

clean:
	$(RM) TAGS class.txt alpha.txt recent.txt

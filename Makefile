#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the Alumni Internet Directory
#      $Id: Makefile,v 3.86 1999/05/24 18:25:15 mradwin Exp mradwin $
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

SCHOOL=mvhs
WWWROOT=/home/web/radwin.org
WWWDIR=$(WWWROOT)/docs/$(SCHOOL)-alumni
CGIDIR=$(WWWROOT)/cgi-bin
DATADIR=$(HOME)/$(SCHOOL)/data
BINDIR=$(HOME)/$(SCHOOL)/bin
CGISRC=$(HOME)/$(SCHOOL)/cgi
AID_UTIL_PL=$(BINDIR)/aid_util.pl
AID_SUBMIT_PL=$(BINDIR)/aid_submit.pl

TAR_AIDDIR=$(SCHOOL)
TAR_IMGDIR=web/images
TAR_WWWDIR=web/$(SCHOOL)-alumni

MKDIR=/bin/mkdir -p
RM=/bin/rm -f
MV=/bin/mv -f
CP=/bin/cp -pf

ADR_MASTER=$(DATADIR)/master.adr

TARFILES= \
	$(TAR_AIDDIR)/README \
	$(TAR_AIDDIR)/COPYING \
	$(TAR_AIDDIR)/Makefile \
	$(TAR_AIDDIR)/bin/aid_* \
	$(TAR_AIDDIR)/bin/generic_config.pl \
	$(TAR_AIDDIR)/bin/$(SCHOOL)_config.pl \
	$(TAR_AIDDIR)/bin/tableheader.pl \
	$(TAR_AIDDIR)/cgi/$(SCHOOL)aid \
	$(TAR_AIDDIR)/cgi/nph-* \
	$(TAR_AIDDIR)/cgi/*.pl \
	$(TAR_AIDDIR)/data/test.adr \
	$(TAR_AIDDIR)/data/*.include \
	$(TAR_WWWDIR)/default.css

SNAPSHOTFILES= \
	$(TAR_AIDDIR) \
	$(TAR_WWWDIR)/default.css \
	$(TAR_WWWDIR)/.htaccess \
	$(TAR_WWWDIR)/master.db

all:	index submit \
	addupdate reunions links faq copyright \
	recent multi_class multi_alpha \
	pages awalt goners download \
	stats vcard pine_book

SYMLINKS=$(AID_SUBMIT_PL) $(AID_UTIL_PL) $(BINDIR)/aid_config.pl \
	$(BINDIR)/$(SCHOOL)_config.pl $(BINDIR)/tableheader.pl
symlinks:
	(cd $(CGIDIR) ; /bin/ln -sf $(SYMLINKS) .; \
	 $(CP) $(CGISRC)/$(SCHOOL)aid $(CGISRC)/nph-aid-search . )
	(cd $(WWWDIR) ; /bin/ln -sf $(CGISRC)/default.css . )

DBFILE=$(WWWDIR)/master.db
dbfile:	$(DBFILE)
$(DBFILE):	$(ADR_MASTER) $(BINDIR)/aid_dbm_write $(AID_UTIL_PL)
	$(RM) ./master.db
	$(BINDIR)/aid_dbm_write $(ADR_MASTER) ./master.db
	$(RM) $(DBFILE)
	$(MV) ./master.db $(DBFILE)
	chmod 0444 $(DBFILE)
	$(BINDIR)/aid_dbm_read -u ./data/master.u $(DBFILE)

VCARD_TS=$(WWWDIR)/vcard/.created
vcard:	$(VCARD_TS)
$(VCARD_TS):	$(DBFILE) $(BINDIR)/aid_write_vcards
	$(MKDIR) $(WWWDIR)/vcard
	$(BINDIR)/aid_write_vcards $(DBFILE) $(WWWDIR)/vcard $(MOD_IDS)

MULTI_ALPHA=$(WWWDIR)/alpha/a-index.html
MULTI_ALPHA_TS=$(WWWDIR)/alpha/.z-index.html
multi_alpha:	$(MULTI_ALPHA_TS)
$(MULTI_ALPHA_TS):	$(DBFILE) $(BINDIR)/aid_multi_alpha_html
	$(MKDIR) $(WWWDIR)/alpha
	$(BINDIR)/aid_multi_alpha_html $(DBFILE)

AWALT=$(WWWDIR)/class/awalt.html
AWALT_TS=$(WWWDIR)/class/.awalt.html
awalt:	$(AWALT_TS)
$(AWALT_TS):	$(DBFILE) $(BINDIR)/aid_class_html
	$(MKDIR) $(WWWDIR)/class
	$(BINDIR)/aid_class_html -a $(DBFILE) $(AWALT)

RECENT=$(WWWDIR)/recent.html
RECENT_TS=$(WWWDIR)/.recent.html
recent:	$(RECENT_TS)
$(RECENT_TS):	$(DBFILE) $(BINDIR)/aid_shortlist_html
	$(BINDIR)/aid_shortlist_html -v -m 0.5 -M 'two weeks' $(DBFILE) $(RECENT)

GONERS=$(WWWDIR)/invalid.html
GONERS_TS=$(WWWDIR)/.invalid.html
goners:	$(GONERS_TS)
$(GONERS_TS):	$(DBFILE) $(BINDIR)/aid_goners_html
	$(BINDIR)/aid_goners_html $(DBFILE) $(GONERS)

PAGES=$(WWWDIR)/pages.html
PAGES_TS=$(WWWDIR)/.pages.html
pages:	$(PAGES_TS)
$(PAGES_TS):	$(DBFILE) $(BINDIR)/aid_class_html
	$(BINDIR)/aid_class_html -w $(DBFILE) $(PAGES)

MULTI_CLASS=$(WWWDIR)/class/.index.html
multi_class:	$(MULTI_CLASS)
$(MULTI_CLASS):	$(DBFILE) $(BINDIR)/aid_multi_class_html
	$(MKDIR) $(WWWDIR)/class
	$(BINDIR)/aid_multi_class_html $(DBFILE)

INDEX=$(WWWDIR)/index.html
INDEX_TS=$(WWWDIR)/.index.html
index:	$(INDEX_TS)
$(INDEX_TS):	$(DATADIR)/index.include $(BINDIR)/aid_home_html $(DBFILE)
	$(BINDIR)/aid_home_html -p0 -i $(DATADIR)/index.include \
		-t '' \
		$(INDEX)

REUNIONS=$(WWWDIR)/etc/reunions.html
REUNIONS_TS=$(WWWDIR)/etc/.reunions.html
reunions:	$(REUNIONS_TS)
$(REUNIONS_TS):	$(DATADIR)/reunions.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_home_html -p11 -i $(DATADIR)/reunions.include \
		-t 'Reunion Information' \
		$(REUNIONS)

LINKS=$(WWWDIR)/etc/links.html
LINKS_TS=$(WWWDIR)/etc/.links.html
links:	$(LINKS_TS)
$(LINKS_TS):	$(DATADIR)/links.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_home_html -p12 -i $(DATADIR)/links.include \
		-t 'Other MVHS and Awalt Resources' \
		$(LINKS)

FAQ=$(WWWDIR)/etc/faq.html
FAQ_TS=$(WWWDIR)/etc/.faq.html
faq:	$(FAQ_TS)
$(FAQ_TS):	$(DATADIR)/faq.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_home_html -p14 -i $(DATADIR)/faq.include \
		-t 'Frequently Asked Questions' \
		$(FAQ)

COPYRIGHT=$(WWWDIR)/etc/copyright.html
COPYRIGHT_TS=$(WWWDIR)/etc/.copyright.html
copyright:	$(COPYRIGHT_TS)
$(COPYRIGHT_TS):	$(DATADIR)/copyright.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_home_html -p16 -i $(DATADIR)/copyright.include \
		-t 'Acceptable Use, Privacy Statement, Copyright' \
		$(COPYRIGHT)
	/bin/ln -sf $(COPYRIGHT) $(WWWDIR)/etc/privacy.html

STATS=$(WWWDIR)/etc/stats.html
stats:	$(STATS)
$(STATS):	$(BINDIR)/aid_stats $(DBFILE)
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_stats $(DBFILE) $(STATS)

SUBMIT=$(WWWDIR)/add/new.html
SUBMIT_TS=$(WWWDIR)/add/.new.html
submit:	$(SUBMIT_TS)
$(SUBMIT_TS):	$(BINDIR)/aid_home_html $(AID_SUBMIT_PL)
	$(MKDIR) $(WWWDIR)/add
	$(BINDIR)/aid_home_html -s -p20 \
		-t 'Add Your Listing to the Directory' \
		$(SUBMIT)

ADDUPDATE=$(WWWDIR)/add/index.html
ADDUPDATE_TS=$(WWWDIR)/add/.index.html
addupdate:	$(ADDUPDATE_TS)
$(ADDUPDATE_TS):	$(DATADIR)/add.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/add
	$(BINDIR)/aid_home_html -p10 -i $(DATADIR)/add.include \
		-t 'Add or Update Your Listing' \
		$(ADDUPDATE)

DOWNLOAD=$(WWWDIR)/download/index.html
DOWNLOAD_TS=$(WWWDIR)/download/.index.html
download:	$(DOWNLOAD_TS)
$(DOWNLOAD_TS):	$(BINDIR)/aid_home_html $(AID_UTIL_PL) $(DBFILE)
	$(MKDIR) $(WWWDIR)/download
	$(BINDIR)/aid_home_html -d -p13 \
		-t 'Download Nickname and Address Book Files' \
		$(DOWNLOAD)

PINE_BOOK=$(HOME)/.addressbook-$(SCHOOL)
pine_book:	$(PINE_BOOK)
$(PINE_BOOK):	$(DBFILE) $(BINDIR)/aid_book
	$(BINDIR)/aid_book -p $(PINE_BOOK) $(DBFILE)
	$(RM) $(PINE_BOOK).lu

alpha.txt:	$(DBFILE) $(BINDIR)/aid_alpha_html
	$(BINDIR)/aid_alpha_html -t $(DBFILE) alpha.txt

class.txt:	$(DBFILE) $(BINDIR)/aid_class_html
	$(BINDIR)/aid_class_html -t $(DBFILE) class.txt

recent.txt:	$(DBFILE) $(BINDIR)/aid_shortlist_html
	$(BINDIR)/aid_shortlist_html -m3 -t $(DBFILE) recent.txt

tar:
	$(MKDIR) $(WWWDIR)/etc
	( cd $(HOME) ; tar cfz $(WWWDIR)/etc/$(SCHOOL)aid.tar.gz $(TARFILES) )

snapshot:
	$(MKDIR) $(WWWDIR)/etc
	( cd $(HOME) ; tar cfz $(WWWDIR)/etc/snapshot.tar.gz $(SNAPSHOTFILES) )

chmod:
	( cd $(WWWDIR) ; chmod -R a+rX * )

clean:
	$(RM) TAGS class.txt alpha.txt recent.txt

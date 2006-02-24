#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the Alumni Internet Directory
#      $Id: Makefile,v 1.4 2006/02/24 00:00:25 mradwin Exp $
#
# Copyright (c) 2006  Michael J. Radwin.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
#  * Redistributions of source code must retain the above
#    copyright notice, this list of conditions and the following
#    disclaimer.
#
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials
#    provided with the distribution. 
#
#  * Neither the name of the High School Alumni Internet Directory
#    nor the names of its contributors may be used to endorse or
#    promote products derived from this software without specific
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

SCHOOL=generic
WWWROOT=/home/mradwin/web/radwin.org
WWWDIR=$(WWWROOT)/$(SCHOOL)
CGIDIR=$(WWWROOT)/$(SCHOOL)/bin
DATADIR=$(HOME)/alumni/$(SCHOOL)/data
BINDIR=$(HOME)/alumni/$(SCHOOL)/bin
CGISRC=$(HOME)/alumni/src/cgi
AID_UTIL_PL=$(BINDIR)/aid_util.pm
AID_SUBMIT_PL=$(BINDIR)/aid_submit.pm

TAR_AIDDIR=alumni/src

MKDIR=/bin/mkdir -p
RM=/bin/rm -f
MV=/bin/mv -f
CP=/bin/cp -pf

TARFILES= \
	$(TAR_AIDDIR)/README \
	$(TAR_AIDDIR)/COPYING \
	$(TAR_AIDDIR)/Makefile \
	$(TAR_AIDDIR)/bin/aid_* \
	$(TAR_AIDDIR)/data/*.include \
	$(TAR_AIDDIR)/data/*.dat \
	$(TAR_AIDDIR)/bin/generic_config.pl \
	$(TAR_AIDDIR)/cgi/[a-z]*

SNAPSHOTFILES= $(TAR_AIDDIR)

all:	index submit \
	addupdate reunions links faq email copyright \
	recent multi_class multi_alpha \
	stats pine_book rss

install:
	$(MKDIR) logs
	($(MKDIR) $(WWWDIR) ; /bin/chmod 0755 $(WWWDIR))
	($(MKDIR) $(CGIDIR) ; /bin/chmod 0755 $(CGIDIR))
	$(CP) $(AID_SUBMIT_PL) $(AID_UTIL_PL) $(BINDIR)/school_config.pl \
	      $(CGISRC)/form $(CGISRC)/search $(CGISRC)/about \
	      $(CGISRC)/go $(CGISRC)/msg $(CGISRC)/remove $(CGISRC)/verify \
	      $(CGIDIR)
	$(CP) $(CGISRC)/default.css $(WWWDIR)
	$(MKDIR) $(WWWDIR)/etc
	$(CP) $(CGISRC)/xml.gif $(WWWDIR)/etc
	$(CP) README $(WWWDIR)/etc/aid-README.txt
	echo 'AddType text/html;charset=ISO-8859-1 html' > $(WWWDIR)/.htaccess
	echo 'AddType text/xml xml rdf' >> $(WWWDIR)/.htaccess
	echo 'SetHandler cgi-script' > $(CGIDIR)/.htaccess

DBFILE=$(DATADIR)/db.timestamp

MULTI_ALPHA_TS=$(WWWDIR)/alpha/.index.html
multi_alpha:	$(MULTI_ALPHA_TS)
$(MULTI_ALPHA_TS):	$(DBFILE) $(BINDIR)/aid_multi_alpha_html
	$(MKDIR) $(WWWDIR)/alpha
	$(BINDIR)/aid_multi_alpha_html $(QUIET) -i "$(MOD_IDS)"

RECENT=$(WWWDIR)/recent.html
RECENT_TS=$(WWWDIR)/.recent.html
recent:	$(RECENT_TS)
$(RECENT_TS):	$(DBFILE) $(BINDIR)/aid_recent_html
	$(BINDIR)/aid_recent_html -d 7 $(RECENT)

MULTI_CLASS=$(WWWDIR)/class/.index.html
multi_class:	$(MULTI_CLASS)
$(MULTI_CLASS):	$(DBFILE) $(BINDIR)/aid_multi_class_html
	$(MKDIR) $(WWWDIR)/class $(WWWDIR)/detail
	$(BINDIR)/aid_multi_class_html -d $(QUIET) -i "$(MOD_IDS)"

INDEX=$(WWWDIR)/index.html
INDEX_TS=$(WWWDIR)/.index.html
index:	$(INDEX_TS)
$(INDEX_TS):	$(DBFILE) $(DATADIR)/index.include $(BINDIR)/aid_home_html
	$(BINDIR)/aid_home_html -p0 -f $(DATADIR)/index.include \
		$(QUIET) -t '' \
		$(INDEX)

REUNIONS=$(WWWDIR)/etc/reunions.html
REUNIONS_TS=$(WWWDIR)/etc/.reunions.html
reunions:	$(REUNIONS_TS)
$(REUNIONS_TS):	$(DATADIR)/reunions.dat $(BINDIR)/aid_reunion_html \
$(BINDIR)/aid_reunion_create
	$(BINDIR)/aid_reunion_create \
		$(DATADIR)/reunions.dat
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_reunion_html $(REUNIONS)

LINKS=$(WWWDIR)/etc/links.html
LINKS_TS=$(WWWDIR)/etc/.links.html
links:	$(LINKS_TS)
$(LINKS_TS):	$(DATADIR)/links.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_home_html -p12 -f $(DATADIR)/links.include \
		$(QUIET) -t 'Links and Other Alumni Directories' \
		$(LINKS)

FAQ=$(WWWDIR)/etc/faq.html
FAQ_TS=$(WWWDIR)/etc/.faq.html
faq:	$(FAQ_TS)
$(FAQ_TS):	$(DATADIR)/faq.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_home_html -p14 -f $(DATADIR)/faq.include \
		$(QUIET) -t 'Frequently Asked Questions' \
		$(FAQ)

EMAIL=$(WWWDIR)/etc/email.html
EMAIL_TS=$(WWWDIR)/etc/.email.html
email:	$(EMAIL_TS)
$(EMAIL_TS):	$(DATADIR)/email.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_home_html -p14 -f $(DATADIR)/email.include \
		$(QUIET) -t 'Email Gateway' \
		$(EMAIL)

COPYRIGHT=$(WWWDIR)/etc/copyright.html
COPYRIGHT_TS=$(WWWDIR)/etc/.copyright.html
copyright:	$(COPYRIGHT_TS)
$(COPYRIGHT_TS):	$(DATADIR)/copyright.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_home_html -p16 -f $(DATADIR)/copyright.include \
		$(QUIET) -t 'Acceptable Use, Privacy Statement, Copyright' \
		$(COPYRIGHT)
	/bin/ln -sf $(COPYRIGHT) $(WWWDIR)/etc/privacy.html

STATS=$(WWWDIR)/etc/stats.html
stats:	$(STATS)
$(STATS):	$(DBFILE) $(BINDIR)/aid_stats
	$(MKDIR) $(WWWDIR)/etc
	$(BINDIR)/aid_stats $(STATS)

RSS=$(WWWDIR)/summary.rdf
RSS_TS=$(WWWDIR)/.summary.rdf
rss:	$(RSS_TS)
$(RSS_TS):	$(DBFILE) $(BINDIR)/aid_rss_summary
	$(BINDIR)/aid_rss_summary $(RSS)

SUBMIT=$(WWWDIR)/add/new.html
SUBMIT_TS=$(WWWDIR)/add/.new.html
submit:	$(SUBMIT_TS)
$(SUBMIT_TS):	$(BINDIR)/aid_home_html $(AID_SUBMIT_PL)
	$(MKDIR) $(WWWDIR)/add
	$(BINDIR)/aid_home_html -s -p20 \
		$(QUIET) -t 'Join the Directory' \
		$(SUBMIT)

ADDUPDATE=$(WWWDIR)/add/index.html
ADDUPDATE_TS=$(WWWDIR)/add/.index.html
addupdate:	$(ADDUPDATE_TS)
$(ADDUPDATE_TS):	$(DATADIR)/add.include $(BINDIR)/aid_home_html
	$(MKDIR) $(WWWDIR)/add
	$(BINDIR)/aid_home_html -p10 -f $(DATADIR)/add.include \
		$(QUIET) -t 'Join or Modify Your Listing' \
		$(ADDUPDATE)

PINE_BOOK=$(HOME)/.addressbook-$(SCHOOL)
pine_book:	$(PINE_BOOK)
$(PINE_BOOK):	$(DBFILE) $(BINDIR)/aid_book
	$(BINDIR)/aid_book -p $(PINE_BOOK)
	$(RM) $(PINE_BOOK).lu

tar:
	$(MKDIR) $(WWWDIR)/etc
	( cd $(HOME) ; tar cfz $(WWWDIR)/etc/aid.tar.gz $(TARFILES) )

snapshot:
	$(MKDIR) $(WWWDIR)/etc
	( cd $(HOME) ; tar cfz $(WWWDIR)/etc/snapshot.tar.gz $(SNAPSHOTFILES) )

chmod:
	( cd $(WWWDIR) ; chmod -R a+rX * )

clean:
	$(RM) TAGS class.txt alpha.txt recent.txt \
	.class.txt .alpha.txt .recent.txt \
	$(MULTI_CLASS) \
	$(MULTI_ALPHA_TS) \
	$(RECENT_TS) \
	$(INDEX_TS) \
	$(REUNIONS_TS) \
	$(LINKS_TS) \
	$(FAQ_TS) \
	$(EMAIL_TS) \
	$(COPYRIGHT_TS) \
	$(SUBMIT_TS) \
	$(ADDUPDATE_TS) \
	$(RSS_TS)

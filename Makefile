#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the MVHS Alumni Internet Directory
#      $Id: Makefile,v 1.42 1997/12/23 04:00:59 mjr Exp mjr $
#

HOMEDIR=/home/divcom/mjr
#HOMEDIR=/home/mjr
WWWDIR=$(HOMEDIR)/public_html/mvhs
RM=/bin/rm -f

TARFILES=Makefile *.pl bin data/*.include
SNAPSHOTFILES=mvhs public_html/mvhs public_html/cgi-bin

all:	adrfile home submit listings reunions links nicknames tech \
	recent alpha class awalt goners pages \
	verbose books

chmod:
	( cd $(WWWDIR) ; chmod -R a+rX * )

adrfile:	$(WWWDIR)/mvhs.adr
$(WWWDIR)/mvhs.adr:	data/mvhs.adr
	cp data/mvhs.adr $(WWWDIR)

mvhs.txt:	data/alpha.adr bin/mv_alpha_html
	bin/mv_alpha_html -t data/alpha.adr mvhs.txt

class.txt:	data/class.adr bin/mv_class_html
	bin/mv_class_html -t data/class.adr class.txt

alpha:	$(WWWDIR)/all.html
$(WWWDIR)/all.html:	data/alpha.adr bin/mv_alpha_html
	bin/mv_alpha_html data/alpha.adr $(WWWDIR)/all.html

class:	$(WWWDIR)/class.html
$(WWWDIR)/class.html:	data/class.adr bin/mv_class_html
	bin/mv_class_html data/class.adr $(WWWDIR)/class.html

awalt:	$(WWWDIR)/awalt.html
$(WWWDIR)/awalt.html:	data/awalt.adr bin/mv_class_html
	bin/mv_class_html -a data/awalt.adr $(WWWDIR)/awalt.html

recent:	$(WWWDIR)/recent.html
$(WWWDIR)/recent.html:	data/date.adr bin/mv_recent_html
	bin/mv_recent_html data/date.adr $(WWWDIR)/recent.html

goners:	$(WWWDIR)/invalid.html
$(WWWDIR)/invalid.html:	data/gsort.adr bin/mv_goners_html
	bin/mv_goners_html data/gsort.adr $(WWWDIR)/invalid.html

pages:	$(WWWDIR)/pages.html
$(WWWDIR)/pages.html:	data/alpha.adr bin/mv_www_html
	bin/mv_www_html data/alpha.adr $(WWWDIR)/pages.html

verbose:	$(WWWDIR)/class/index.html
$(WWWDIR)/class/index.html:	data/class.adr bin/mv_verbose_html
	bin/mv_verbose_html data/class.adr

home:	$(WWWDIR)/index.html
$(WWWDIR)/index.html:	data/index.include bin/mv_home_html mv_util.pl data/mvhs.adr
	bin/mv_home_html -p0 -i data/index.include \
		-t 'Welcome to the MVHS Alumni Internet Directory!' \
		$(WWWDIR)/index.html

listings:	$(WWWDIR)/listings.html
$(WWWDIR)/listings.html:	data/listings.include bin/mv_home_html mv_util.pl
	bin/mv_home_html -p10 -i data/listings.include \
		-t 'Listings: email addresses and web pages' \
		$(WWWDIR)/listings.html

reunions:	$(WWWDIR)/reunions.html
$(WWWDIR)/reunions.html:	data/reunions.include bin/mv_home_html mv_util.pl
	bin/mv_home_html -p11 -i data/reunions.include \
		-t 'Reunions: when, where, who to contact' \
		$(WWWDIR)/reunions.html

links:	$(WWWDIR)/links.html
$(WWWDIR)/links.html:	data/links.include bin/mv_home_html mv_util.pl
	bin/mv_home_html -p12 -i data/links.include \
		-t 'Links: other MVHS and Awalt websites' \
		$(WWWDIR)/links.html

nicknames:	$(WWWDIR)/nicknames.html
$(WWWDIR)/nicknames.html:	data/nicknames.include bin/mv_home_html mv_util.pl
	bin/mv_home_html -p13 -i data/nicknames.include \
		-t 'Nicknames: address books for your e-mail program' \
		$(WWWDIR)/nicknames.html

tech:	$(WWWDIR)/tech.html
$(WWWDIR)/tech.html:	data/tech.include bin/mv_home_html mv_util.pl
	bin/mv_home_html -p14 -i data/tech.include \
		-t 'Tech Notes: info about the Directory' \
		$(WWWDIR)/tech.html

submit:	$(WWWDIR)/add.html
$(WWWDIR)/add.html:	bin/mv_home_html mv_util.pl
	bin/mv_home_html -s -p6 $(WWWDIR)/add.html

books:	$(WWWDIR)/mvhs.vcf
$(WWWDIR)/mvhs.vcf:	data/alpha.adr bin/mv_book
	bin/mv_book \
		-p $(WWWDIR)/pine.txt \
		-e $(WWWDIR)/elm.txt \
		-b $(WWWDIR)/berkeley.txt \
		-w $(WWWDIR)/eudora.txt \
		-m $(WWWDIR)/eudorapro.txt \
		-n $(WWWDIR)/address-book.html \
		-l $(WWWDIR)/address-book.ldif \
		-v $(WWWDIR)/mvhs.vcf \
		data/alpha.adr

data/gsort.adr:	data/goners.adr
	sort -t\; +3 -6 data/goners.adr > data/gsort.adr

data/alpha.adr:	data/mvhs.adr
	sort -t\; +3 -6 data/mvhs.adr > data/alpha.adr

data/class.adr:	data/mvhs.adr
	sort -t\; +7 -8 +3 -6 data/mvhs.adr > data/class.adr

data/awalt.adr:	data/class.adr
	grep -i awalt data/class.adr > data/awalt.adr

data/date.adr:	data/mvhs.adr
	sort data/mvhs.adr > data/date.adr

tar:
	tar cf $(WWWDIR)/mvhsaid.tar $(TARFILES)
	gzip -f $(WWWDIR)/mvhsaid.tar

snapshot:
	( cd $(HOMEDIR) ; tar cf $(WWWDIR)/snapshot.tar $(SNAPSHOTFILES) )
	gzip -f $(WWWDIR)/snapshot.tar

clean:
	$(RM) TAGS class.txt mvhs.txt data/class.adr data/alpha.adr
	$(RM) data/gsort.adr data/date.adr data/awalt.adr

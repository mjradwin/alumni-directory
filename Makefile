#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the MVHS Alumni Internet Directory
#      $Id: Makefile,v 1.45 1997/12/31 21:15:04 mjr Exp mjr $
#

HOMEDIR=/home/divcom/mjr
#HOMEDIR=/home/mjr
WWWDIR=$(HOMEDIR)/public_html/mvhs
RM=/bin/rm -f

TARFILES=Makefile *.pl bin data/*.include
SNAPSHOTFILES=mvhs public_html/mvhs/*.gif \
	public_html/mvhs/whatsnew public_html/cgi-bin

all:	adrfile home submit listings reunions links nicknames tech \
	recent alpha class awalt goners pages \
	verbose books

ADRFILE=$(WWWDIR)/mvhs.adr
adrfile:	$(ADRFILE)
$(ADRFILE):	data/mvhs.adr
	cp data/mvhs.adr $(WWWDIR)

ALPHA=$(WWWDIR)/all.html
alpha:	$(ALPHA)
$(ALPHA):	data/alpha.adr bin/aid_alpha_html
	bin/aid_alpha_html data/alpha.adr $(ALPHA)

CLASS=$(WWWDIR)/class.html
class:	$(CLASS)
$(CLASS):	data/class.adr bin/aid_class_html
	bin/aid_class_html data/class.adr $(CLASS)

AWALT=$(WWWDIR)/awalt.html
awalt:	$(AWALT)
$(AWALT):	data/awalt.adr bin/aid_class_html
	bin/aid_class_html -a data/awalt.adr $(AWALT)

RECENT=$(WWWDIR)/recent.html
recent:	$(RECENT)
$(RECENT):	data/date.adr bin/aid_recent_html
	bin/aid_recent_html data/date.adr $(RECENT)

GONERS=$(WWWDIR)/invalid.html
goners:	$(GONERS)
$(GONERS):	data/gsort.adr bin/aid_goners_html
	bin/aid_goners_html data/gsort.adr $(GONERS)

PAGES=$(WWWDIR)/pages.html
pages:	$(PAGES)
$(PAGES):	data/alpha.adr bin/aid_www_html
	bin/aid_www_html data/alpha.adr $(PAGES)

VERBOSE=$(WWWDIR)/class/index.html
verbose:	$(VERBOSE)
$(VERBOSE):	data/class.adr bin/aid_verbose_html
	mkdir -p $(WWWDIR)/class
	bin/aid_verbose_html data/class.adr

HOME=$(WWWDIR)/index.html
home:	$(HOME)
$(HOME):	data/index.include bin/aid_home_html aid_util.pl data/mvhs.adr
	bin/aid_home_html -p0 -i data/index.include \
		-t 'Welcome to the MVHS Alumni Internet Directory!' \
		$(HOME)

LISTINGS=$(WWWDIR)/listings.html
listings:	$(LISTINGS)
$(LISTINGS):	data/listings.include bin/aid_home_html aid_util.pl
	bin/aid_home_html -p10 -i data/listings.include \
		-t 'Listings: email addresses and web pages' \
		$(LISTINGS)

REUNIONS=$(WWWDIR)/reunions.html
reunions:	$(REUNIONS)
$(REUNIONS):	data/reunions.include bin/aid_home_html aid_util.pl
	bin/aid_home_html -p11 -i data/reunions.include \
		-t 'Reunions: when, where, who to contact' \
		$(REUNIONS)

LINKS=$(WWWDIR)/links.html
links:	$(LINKS)
$(LINKS):	data/links.include bin/aid_home_html aid_util.pl
	bin/aid_home_html -p12 -i data/links.include \
		-t 'Links: other MVHS and Awalt websites' \
		$(LINKS)

NICKNAMES=$(WWWDIR)/books/index.html
nicknames:	$(NICKNAMES)
$(NICKNAMES):	data/nicknames.include bin/aid_home_html aid_util.pl
	mkdir -p $(WWWDIR)/books
	bin/aid_home_html -p13 -i data/nicknames.include \
		-t 'Nicknames: address books for your e-mail program' \
		$(NICKNAMES)

TECH=$(WWWDIR)/tech.html
tech:	$(TECH)
$(TECH):	data/tech.include bin/aid_home_html aid_util.pl
	bin/aid_home_html -p14 -i data/tech.include \
		-t 'Tech Notes: info about the Directory' \
		$(TECH)

SUBMIT=$(WWWDIR)/add.html
submit:	$(SUBMIT)
$(SUBMIT):	bin/aid_home_html aid_util.pl
	bin/aid_home_html -s -p6 $(SUBMIT)

BOOKS=$(WWWDIR)/books/mvhs.vcf
books:	$(BOOKS)
$(BOOKS):	data/alpha.adr bin/aid_book
	mkdir -p $(WWWDIR)/books
	bin/aid_book \
		-p $(WWWDIR)/books/pine.txt \
		-e $(WWWDIR)/books/elm.txt \
		-b $(WWWDIR)/books/berkeley.txt \
		-w $(WWWDIR)/books/eudora.txt \
		-m $(WWWDIR)/books/eudorapro.txt \
		-n $(WWWDIR)/books/address-book.html \
		-l $(WWWDIR)/books/address-book.ldif \
		-v $(WWWDIR)/books/mvhs.vcf \
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

mvhs.txt:	data/alpha.adr bin/aid_alpha_html
	bin/aid_alpha_html -t data/alpha.adr mvhs.txt

class.txt:	data/class.adr bin/aid_class_html
	bin/aid_class_html -t data/class.adr class.txt

tar:
	tar cf $(WWWDIR)/mvhsaid.tar $(TARFILES)
	gzip -f $(WWWDIR)/mvhsaid.tar

snapshot:
	( cd $(HOMEDIR) ; tar cf $(WWWDIR)/snapshot.tar $(SNAPSHOTFILES) )
	gzip -f $(WWWDIR)/snapshot.tar

chmod:
	( cd $(WWWDIR) ; chmod -R a+rX * )

clean:
	$(RM) TAGS class.txt mvhs.txt data/class.adr data/alpha.adr
	$(RM) data/gsort.adr data/date.adr data/awalt.adr

#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the MVHS Alumni Internet Directory
#      $Id: Makefile,v 1.27 1997/08/28 02:09:19 mjr Exp mjr $
#

WWWDIR=/home/divcom/mjr/public_html/mvhs
RM=/bin/rm -f

TARFILES=Makefile *.pl index.include bin data

all:	adrfile home submit new alpha class awalt goners pages books

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
	bin/mv_class_html data/awalt.adr $(WWWDIR)/awalt.html

new:	$(WWWDIR)/recent.html
$(WWWDIR)/recent.html:	data/date.adr bin/mv_new_html
	bin/mv_new_html data/date.adr $(WWWDIR)/recent.html

goners:	$(WWWDIR)/invalid.html
$(WWWDIR)/invalid.html:	data/gsort.adr bin/mv_goners_html
	bin/mv_goners_html data/gsort.adr $(WWWDIR)/invalid.html

pages:	$(WWWDIR)/pages.html
$(WWWDIR)/pages.html:	data/alpha.adr bin/mv_www_html
	bin/mv_www_html data/alpha.adr $(WWWDIR)/pages.html

home:	$(WWWDIR)/index.html
$(WWWDIR)/index.html:	index.include bin/mv_home_html mv_util.pl
	bin/mv_home_html -i index.include

submit:	$(WWWDIR)/add.html
$(WWWDIR)/add.html:	bin/mv_home_html mv_util.pl
	bin/mv_home_html -s

books:	data/alpha.adr bin/mv_book
	bin/mv_book -p data/alpha.adr $(WWWDIR)/pine.txt
	bin/mv_book -e data/alpha.adr $(WWWDIR)/elm.txt
	bin/mv_book -b data/alpha.adr $(WWWDIR)/berkeley.txt
	bin/mv_book -w data/alpha.adr $(WWWDIR)/eudora.txt
	bin/mv_book -m data/alpha.adr $(WWWDIR)/eudorapro.txt
	bin/mv_book -n data/alpha.adr $(WWWDIR)/address-book.html
	bin/mv_book -v data/alpha.adr $(WWWDIR)/mvhs.vcf
	touch books

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
	tar cf $(WWWDIR)/mvhs_db.tar $(TARFILES)

backup:
	ci -l mv_* tableheader.pl Makefile

clean:
	$(RM) TAGS class.txt mvhs.txt data/class.adr data/alpha.adr
	$(RM) data/gsort.adr data/date.adr

#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the MVHS Alumni Internet Directory
#      $Id: Makefile,v 1.18 1997/03/29 17:44:24 mjr Exp $
#

WWWDIR=/home/divcom/mjr/public_html/mvhs
CGIDIR=/home/divcom/mjr/public_html/cgi-bin
BINDIR=/home/divcom/mjr/bin

TARFILES=Makefile mvhs.adr goners.adr mv_* tableheader.pl \
	-C $(BINDIR) web_add \
	-C $(CGIDIR) mvhsaid cgi-lib.pl \
	-C $(WWWDIR) .home.include .submit.hdr .submit.ftr

all:	alpha class new goners pages books adrfile home submit

chmod:
	( cd $(WWWDIR) ; chmod -R a+rX * )

adrfile:	$(WWWDIR)/mvhs.adr
$(WWWDIR)/mvhs.adr:	mvhs.adr
	cp mvhs.adr $(WWWDIR)

mvhs.txt:	alpha.adr mv_alpha_html
	./mv_alpha_html -t alpha.adr mvhs.txt

class.txt:	class.adr mv_class_html
	./mv_class_html -t class.adr class.txt

alpha:	$(WWWDIR)/all.html
$(WWWDIR)/all.html:	alpha.adr mv_alpha_html
	./mv_alpha_html alpha.adr $(WWWDIR)/all.html

class:	$(WWWDIR)/class.html
$(WWWDIR)/class.html:	class.adr mv_class_html
	./mv_class_html class.adr $(WWWDIR)/class.html

new:	$(WWWDIR)/recent.html
$(WWWDIR)/recent.html:	alpha.adr mv_new_html
	./mv_new_html alpha.adr $(WWWDIR)/recent.html

goners:	$(WWWDIR)/invalid.html
$(WWWDIR)/invalid.html:	gsort.adr mv_goners_html
	./mv_goners_html gsort.adr $(WWWDIR)/invalid.html

pages:	$(WWWDIR)/pages.html
$(WWWDIR)/pages.html:	alpha.adr mv_www_html
	./mv_www_html alpha.adr $(WWWDIR)/pages.html

home:	$(WWWDIR)/index.html
$(WWWDIR)/index.html:	$(WWWDIR)/.home.include mv_home_html
	./mv_home_html -i

submit:	$(WWWDIR)/add.html
$(WWWDIR)/add.html:	mv_home_html mv_util.pl
	./mv_home_html -s

books:	alpha.adr mv_book
	./mv_book -p alpha.adr $(WWWDIR)/pine.txt
	./mv_book -e alpha.adr $(WWWDIR)/elm.txt
	./mv_book -b alpha.adr $(WWWDIR)/berkeley.txt
	./mv_book -w alpha.adr $(WWWDIR)/eudora.txt
	./mv_book -m alpha.adr $(WWWDIR)/eudorapro.txt
	./mv_book -n alpha.adr $(WWWDIR)/address-book.html
	./mv_book -v alpha.adr $(WWWDIR)/mvhs.vcf
	touch books

gsort.adr:	goners.adr
	sort -t\; +3 -6 goners.adr > gsort.adr

alpha.adr:	mvhs.adr
	sort -t\; +3 -6 mvhs.adr > alpha.adr

class.adr:	mvhs.adr
	sort -t\; +7 -8 +3 -6 mvhs.adr > class.adr

tar:
	tar cf $(WWWDIR)/mvhs_db.tar $(TARFILES)

backup:
	ci -l mv_* tableheader.pl Makefile

clean:
	$(RM) TAGS class.txt mvhs.txt class.adr alpha.adr

#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the MVHS Alumni Internet Directory
#      $Id: Makefile,v 1.13 1997/03/25 17:52:33 mjr Exp $
#

WWWDIR=/home/divcom/mjr/public_html/mvhs
CGIDIR=/home/divcom/mjr/public_html/cgi-bin
CGIFILE=mvhsaid
TARFILES=Makefile mvhs.adr goners.adr mv_* tableheader.pl \
	-C $(CGIDIR) $(CGIFILE) \
	-C $(WWWDIR) .home.include .submit.hdr .submit.ftr

all:	alpha grad new goners pages books adrfile home submit
	( cd $(WWWDIR) ; chmod 0644 * )

adrfile:	$(WWWDIR)/mvhs.adr
$(WWWDIR)/mvhs.adr:	mvhs.adr
	cp mvhs.adr $(WWWDIR)

mvhs.txt:	alpha.adr mv_alpha_html
	./mv_alpha_html -t alpha.adr mvhs.txt

alpha:	$(WWWDIR)/all.html mv_alpha_html
$(WWWDIR)/all.html:	alpha.adr
	./mv_alpha_html alpha.adr $(WWWDIR)/all.html

grad:	$(WWWDIR)/class.html mv_grad_html
$(WWWDIR)/class.html:	class.adr
	./mv_grad_html class.adr $(WWWDIR)/class.html

new:	$(WWWDIR)/recent.html mv_new_html
$(WWWDIR)/recent.html:	alpha.adr
	./mv_new_html alpha.adr $(WWWDIR)/recent.html

goners:	$(WWWDIR)/invalid.html mv_goners_html
$(WWWDIR)/invalid.html:	gsort.adr
	./mv_goners_html gsort.adr $(WWWDIR)/invalid.html

pages:	$(WWWDIR)/pages.html mv_www_html
$(WWWDIR)/pages.html:	alpha.adr
	./mv_www_html alpha.adr $(WWWDIR)/pages.html

home:	$(WWWDIR)/index.html mv_home_html
$(WWWDIR)/index.html:	$(WWWDIR)/.home.include mv_home_html
	./mv_home_html -i

submit:	$(WWWDIR)/add.html mv_home_html mv_util.pl
$(WWWDIR)/add.html:	mv_home_html
	./mv_home_html -s

books:	alpha.adr
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
	$(RM) $(CGIFILE) TAGS
	$(RM) mvhs.txt class.adr alpha.adr

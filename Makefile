#
#     FILE: Makefile
#   AUTHOR: Michael J. Radwin
#    DESCR: Makefile for building the MVHS Alumni Internet Directory
#      $Id: mv_util.pl,v 1.12 1997/01/20 19:07:35 mjr Exp mjr $
#

WWWDIR=/pro/web/web/people/mjr/mvhs
CGIDIR=/pro/web/cgi-bin
CGIFILE=mjr-mvhs.cgi
LIBDIR=/home/mjr/lib

#WWWDIR=/home/divcom/mjr/public_html/mvhs
#CGIDIR=/home/divcom/mjr/public_html/cgi-bin
#CGIFILE=mvhsaid
#LIBDIR=/home/divcom/mjr/lib

all:	alpha grad new goners pages books dbtar adrfile home submit
	( cd $(WWWDIR) ; chmod 0644 * ; /usr/local/bin/webupdate )
#	( cd $(WWWDIR) ; chmod 0644 * )

adrfile:	$(WWWDIR)/mvhs.adr
$(WWWDIR)/mvhs.adr:	mvhs.adr
	cp mvhs.adr $(WWWDIR)

mvhs.txt:	alpha.adr
	./mv_alpha_html -t alpha.adr mvhs.txt

alpha:	$(WWWDIR)/all.html
$(WWWDIR)/all.html:	alpha.adr
	./mv_alpha_html alpha.adr $(WWWDIR)/all.html

grad:	$(WWWDIR)/class.html
$(WWWDIR)/class.html:	class.adr
	./mv_grad_html class.adr $(WWWDIR)/class.html

new:	$(WWWDIR)/recent.html
$(WWWDIR)/recent.html:	alpha.adr
	./mv_new_html alpha.adr $(WWWDIR)/recent.html

goners:	$(WWWDIR)/invalid.html
$(WWWDIR)/invalid.html:	gsort.adr
	./mv_goners_html gsort.adr $(WWWDIR)/invalid.html

pages:	$(WWWDIR)/pages.html
$(WWWDIR)/pages.html:	alpha.adr
	./mv_www_html alpha.adr $(WWWDIR)/pages.html

home:	$(WWWDIR)/home.html
$(WWWDIR)/home.html:	$(WWWDIR)/.home.include mv_home_html
	./mv_home_html -i

submit:	$(WWWDIR)/add.html
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
	sort -t: +3 -5 goners.adr > gsort.adr

alpha.adr:	mvhs.adr
	sort -t: +3 -5 mvhs.adr > alpha.adr

class.adr:	mvhs.adr
	sort -t: +6 -7 +3 -5 mvhs.adr > class.adr

dbtar:	$(WWWDIR)/mvhs_db.tar
$(WWWDIR)/mvhs_db.tar:
	cp $(CGIDIR)/$(CGIFILE) .
	cp $(LIBDIR)/tableheader.pl $(LIBDIR)/mv_util.pl .
	tar cf $(WWWDIR)/mvhs_db.tar mv_* tableheader.pl $(CGIFILE) Makefile
	$(RM) $(CGIFILE) tableheader.pl mv_util.pl

backup:
	ci -l mv_* Makefile

clean:
	$(RM) $(CGIFILE) tableheader.pl mv_util.pl TAGS
	$(RM) mvhs.txt class.adr gsort.adr alpha.adr

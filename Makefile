WWWDIR=/pro/web/web/people/mjr/mvhs

all:	alpha grad new goners pages books dbtar adrfile home submit
	( cd ${WWWDIR} ; chmod 0644 * ; /usr/local/bin/webupdate )

adrfile:	${WWWDIR}/mvhs.adr
${WWWDIR}/mvhs.adr:	mvhs.adr
	cp mvhs.adr ${WWWDIR}

mvhs.txt:	alpha.adr
	./mv_alpha_html -t alpha.adr mvhs.txt

alpha:	${WWWDIR}/all.html
${WWWDIR}/all.html:	alpha.adr
	./mv_alpha_html alpha.adr ${WWWDIR}/all.html

grad:	${WWWDIR}/class.html
${WWWDIR}/class.html:	class.adr
	./mv_grad_html class.adr ${WWWDIR}/class.html

new:	${WWWDIR}/recent.html
${WWWDIR}/recent.html:	alpha.adr
	./mv_new_html alpha.adr ${WWWDIR}/recent.html

goners:	${WWWDIR}/invalid.html
${WWWDIR}/invalid.html:	goners.adr
	./mv_goners_html goners.adr ${WWWDIR}/invalid.html

pages:	${WWWDIR}/pages.html
${WWWDIR}/pages.html:	alpha.adr
	./mv_www_html alpha.adr ${WWWDIR}/pages.html

home:	${WWWDIR}/home.html
${WWWDIR}/home.html:	${WWWDIR}/.home.include mv_home_html
	./mv_home_html -i

submit:	${WWWDIR}/add.html
# ${WWWDIR}/add.html:	mv_util.pl mv_home_html
${WWWDIR}/add.html:	mv_home_html
	./mv_home_html -s

books:	alpha.adr
	./mv_book -p alpha.adr ${WWWDIR}/pine.txt
	./mv_book -e alpha.adr ${WWWDIR}/elm.txt
	./mv_book -b alpha.adr ${WWWDIR}/berkeley.txt
	./mv_book -w alpha.adr ${WWWDIR}/eudora.txt
	./mv_book -m alpha.adr ${WWWDIR}/eudorapro.txt
	./mv_book -n alpha.adr ${WWWDIR}/address-book.html
	./mv_book -v alpha.adr ${WWWDIR}/mvhs.vcf
	touch books

alpha.adr:	mvhs.adr
	sort -t: +3 -5 mvhs.adr > alpha.adr

class.adr:	mvhs.adr
	sort -t: +6 -7 +3 -5 mvhs.adr > class.adr

dbtar:	${WWWDIR}/mvhs_db.tar
${WWWDIR}/mvhs_db.tar:
	cp /pro/web/cgi-bin/mjr-mvhs.cgi .
	cp /home/mjr/lib/tableheader.pl /home/mjr/lib/mv_util.pl .
	tar cf ${WWWDIR}/mvhs_db.tar mv_* tableheader.pl mjr-mvhs.cgi Makefile
	rm -f mjr-mvhs.cgi tableheader.pl mv_util.pl

backup:
	ci -l mv_* Makefile

WWWDIR=/pro/web/web/people/mjr/mvhs

all:	alpha.adr grad new mvhs.txt goners pages books mvhs_db.tar webupdate

webupdate:
	cp mvhs.adr ${WWWDIR}
	( cd ${WWWDIR} ; chmod 0644 * ; /usr/local/bin/webupdate )

mvhs.txt:	alpha.adr
	./mv_alpha_html -t alpha.adr mvhs.txt
	./mv_alpha_html alpha.adr ${WWWDIR}/all.html

grad:	class.adr
	./mv_grad_html class.adr ${WWWDIR}/class.html
	touch grad

new:	alpha.adr
	./mv_new_html alpha.adr ${WWWDIR}/recent.html
	touch new

goners:	goners.adr
	./mv_goners_html goners.adr ${WWWDIR}/invalid.html
	( cd ${WWWDIR} ; chmod 0644 invalid.html ; /usr/local/bin/webupdate invalid.html )
	touch goners

pages:	alpha.adr
	./mv_www_html alpha.adr ${WWWDIR}/pages.html
	touch pages


home:	${WWWDIR}/.home.include mv_home_html
	./mv_home_html -i
	( cd ${WWWDIR} ; chmod 0644 home.html ; /usr/local/bin/webupdate home.html )

submit:	mv_util.pl mv_home_html
	./mv_home_html -s
	( cd ${WWWDIR} ; chmod 0644 add.html ; /usr/local/bin/webupdate add.html )

books:	alpha.adr
	./mv_book -p alpha.adr ${WWWDIR}/pine.txt
	./mv_book -e alpha.adr ${WWWDIR}/elm.txt
	./mv_book -b alpha.adr ${WWWDIR}/berkeley.txt
	./mv_book -w alpha.adr ${WWWDIR}/eudora.txt
	./mv_book -m alpha.adr ${WWWDIR}/eudorapro.txt
	./mv_book -n alpha.adr ${WWWDIR}/address-book.html
	touch books

alpha.adr:	mvhs.adr
	sort -t: +3 -5 mvhs.adr > alpha.adr

class.adr:	mvhs.adr
	sort -t: +6 -7 mvhs.adr > class.adr

mvhs_db.tar:	
	cp /pro/web/cgi-bin/mjr-mvhs.cgi .
	tar cf mvhs_db.tar mv_* mjr-mvhs.cgi regen
	cp mvhs_db.tar ${WWWDIR}

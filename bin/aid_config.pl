#
#     FILE: aid_config.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: configuration for Alumni Internet Directory
#      $Id: aid_util.pl,v 4.5 1999/02/01 23:42:12 mradwin Exp mradwin $
#

# radwin.org (FreeBSD 2.2.2) configuration
%aid_util'config =   #'#
    ('admin_name',   'Michael John Radwin',
     'admin_email',  "mvhs-alumni\@radwin.org",
     'school',       'Mountain View High School',
     'short_school', 'MVHS',
     'admin_school', "Mountain View High School, Class of '93",
     'admin_phone',  '408-536-2554',
     'admin_url',    'http://www.radwin.org/michael/',
     'master_srv',   'www.radwin.org',
     'master_path',  '/mvhs-alumni/',
     'image_path',   '/images/',
     'cgi_path',     '/cgi-bin/mvhsaid',
     'index_page',   'index.html',
     'wwwdir',       '/home/web/radwin.org/docs/mvhs-alumni/',
     'aiddir',       '/home/users/mradwin/mvhs/',
     'sendmail',     '/usr/sbin/sendmail',
     'mailprog',     '/usr/bin/mail',
     'cat',          '/bin/cat',
     'cp',           '/bin/cp',
     'make',         '/usr/bin/make',
     'mailto',       "mvhs-submissions\@radwin.org",
     'mailsubj',     'MVHSAID',
     'spoolfile',    '/var/mail/mradwin',
     'rcsid',        "$aid_util'rcsid",
     );

$aid_util'site_tags = #'#
"  <meta name=\"keywords\"    content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">\n  <meta name=\"description\" content=\"Alumni e-mail and web page directory for Mountain View High School (MVHS) and Awalt High School in Mountain View, CA. Updated $aid_util'caldate.\">\n  <meta name=\"author\"  content=\"$aid_util'config{'admin_name'}\">\n  <link rev=\"made\"     href=\"mailto:" . $aid_util'config{'admin_email'} . "\">\n  <link rel=\"contents\" href=\"http://" . $aid_util'config{'master_srv'} . $aid_util'config{'master_path'} . "\" title=\"Home page for MVHS Alumni Internet Directory\">";

$aid_util'disclaimer = #'#
"<a name=\"disclaimer\">Acceptable use:</a> the Alumni Internet
Directory is provided solely for the information of the Mountain View
High School and Awalt High School communities.  Any redistribution
outside of this community, or solicitation of business or contributions
from individuals listed in this publication is forbidden.";

1;

#
#     FILE: generic_config.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: configuration variables for Alumni Internet Directory
#      $Id: generic_config.pl,v 5.18 2003/10/30 17:20:59 mradwin Exp mradwin $
#
# Copyright (c) 2003  Michael J. Radwin.
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

$aid_util::rcsid =
 '$Id: generic_config.pl,v 5.18 2003/10/30 17:20:59 mradwin Exp mradwin $';

# Generic HS on example.com (FreeBSD 2.2.2) configuration
%aid_util::config =  
    (
     'school',       'Generic High School',
     'short_school', 'Generic',
     'admin_name',   'Jane Smith',
     'admin_email',  "generic-alumni-admin\@example.com",
     'devnull_email',"dev-null\@example.com",
     'admin_school', "Generic High School, Class of '93",
     'admin_url',    'http://www.example.com/~jsmith/',
     'master_srv',   'www.example.com',
     'master_path',  '/~jsmith/generic/',
     'verify_cgi',   '/~jsmith/generic/bin/verify',
     'remove_cgi',   '/~jsmith/generic/bin/remove',
     'search_cgi',   '/~jsmith/generic/bin/search',
     'vcard_cgi',    '/~jsmith/generic/bin/vcard',
     'goners_cgi',   '/~jsmith/generic/bin/form/gone',
     'download_cgi', '/~jsmith/generic/bin/alumni.txt',
     'go_cgi',       '/~jsmith/generic/bin/go',
     'about_cgi',    '/~jsmith/generic/bin/about',
     'submit_cgi',   '/~jsmith/generic/bin/form/sub',
     'update_cgi',   '/~jsmith/generic/bin/form/upd',
     'confirm_cgi',  '/~jsmith/generic/bin/form/cnf',
     'yab_cgi',      '/~jsmith/generic/bin/yab',
     'message_cgi',  '/~jsmith/generic/bin/msg',
     'index_page',   'index.html',
     'wwwdir',       $ENV{'HOME'} . '/public_html/generic/',
     'dbmfile',      $ENV{'HOME'} . '/public_html/generic/master.db',
     'staging',      $ENV{'HOME'} . '/public_html/generic/staging.db',
     'reunions',     $ENV{'HOME'} . '/public_html/generic/reunions.db',
     'limit',        $ENV{'HOME'} . '/public_html/generit/limit.db',
     'aiddir',       $ENV{'HOME'} . '/alumni/generic/',
     'smtp_svr',     'smtp.example.com',
     'make',         '/usr/bin/make',
     'mailto',       "generic-submissions\@example.com",
     'spoolfile',    '/var/mail/jsmith',
     'rcsid',        "$aid_util::rcsid",
     'html_ad', '',
     'descr_long',  'The Generic School Alumni Internet Directory is an e-mail/web page listing of alumni, faculty and staff from Generic High School in Anytown, California.',
     'max_gradyear', ((localtime(time))[5] + 1904),
     );

$aid_util::author_meta =
"<meta name=\"author\" content=\"$aid_util::config{'admin_name'}\">\n<link rev=\"made\" href=\"mailto:" . $aid_util::config{'admin_email'} . "\">";

$aid_util::navigation_meta =
    "<link rel=\"start\" href=\"http://" .
    $aid_util::config{'master_srv'} .
    $aid_util::config{'master_path'} .
    "\" title=\"" . $aid_util::config{'short_school'} .
    " Alumni Internet Directory\">";

$aid_util::descr_meta =
"<meta name=\"keywords\" content=\"" . $aid_util::config{'school'} . ", " .
$aid_util::config{'short_school'} . ", Anytown, California, reunion, alumni, directory\">\n<meta name=\"description\" content=\"Alumni e-mail and web page directory for " . $aid_util::config{'school'} . " in Anytown, CA. Updated __DATE__.\">";

$aid_util::disclaimer =
"<a name=\"disclaimer\">Acceptable use:</a> the Alumni Internet
Directory is provided solely for the information of the
" . $aid_util::config{'school'} . " community.
Any redistribution outside of this community, or solicitation of
business or contributions from individuals listed in this publication is
forbidden.";

# colors
$aid_util::header_bg  = '99ccff';
$aid_util::header_fg  = '000000';

$aid_util::cell_bg    = 'eeeeee';
$aid_util::cell_fg    = '000000';

$aid_util::star_fg    = 'ff0000';

$aid_util::body_bg    = 'ffffff';
$aid_util::body_fg    = '000000';
$aid_util::body_link  = '0000cc';
$aid_util::body_vlink = '990099';

if ($^W && 0)
{
    $aid_util::disclaimer = '';
    $aid_util::author_meta = $aid_util::navigation_meta = $aid_util::descr_meta;

    $aid_util::header_bg  = $aid_util::header_fg  = '';
    $aid_util::cell_bg    = $aid_util::cell_fg  = '';
    $aid_util::star_fg    = '';
    $aid_util::body_bg    = $aid_util::body_fg =
	$aid_util::body_link  = $aid_util::body_vlink = '';
}

1;

#
#     FILE: generic_config.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: configuration variables for Alumni Internet Directory
#      $Id: generic_config.pl,v 5.8 1999/06/14 22:55:31 mradwin Exp mradwin $
#
#   Copyright (c) 1995-1999  Michael John Radwin
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# $ht_empty_close_tag = ' />';
$ht_empty_close_tag = '>';

$aid_util'rcsid =
 '$Id: generic_config.pl,v 5.8 1999/06/14 22:55:31 mradwin Exp mradwin $';

# Generic HS on bogus-domain.org (FreeBSD 2.2.2) configuration
%aid_util'config =   #'#
    (
     'school',       'Generic High School',
     'short_school', 'Generic',
     'admin_name',   'Jane Smith',
     'admin_email',  "generic-alumni-admin\@bogus-domain.org",
     'admin_school', "Generic High School, Class of '93",
     'admin_url',    'http://www.bogus-domain.org/~jsmith/',
     'master_srv',   'www.bogus-domain.org',
     'master_path',  '/~jsmith/generic/',
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
     'index_page',   'index.html',
     'wwwdir',       '/home/jsmith/public_html/generic/',
     'dbmfile',      '/home/jsmith/public_html/generic/master.db',
     'aiddir',       '/home/jsmith/generic/',
     'sendmail',     '/usr/sbin/sendmail',
     'mailprog',     '/usr/bin/mail',
     'make',         '/usr/bin/make',
     'mailto',       "generic-submissions\@bogus-domain.org",
     'spoolfile',    '/var/mail/jsmith',
     'rcsid',        "$aid_util'rcsid",
     'sub_beg_str',  '_AID_BEGIN_SUBMISSION_',
     'sub_end_str',  '_AID_END_SUBMISSION_',
     'note_beg_str', '_AID_BEGIN_NOTE_',
     'note_end_str', '_AID_END_NOTE_',
     'mail_intro',   
        "This e-mail was sent to you by the Generic High\n" .
        "School Alumni Internet Directory:",
     'html_ad', '',
     );

$aid_util'author_meta = #'#
"<meta name=\"author\" content=\"$aid_util'config{'admin_name'}\"${ht_empty_close_tag}\n<link rev=\"made\" href=\"mailto:" . $aid_util'config{'admin_email'} . "\"${ht_empty_close_tag}";

$aid_util'navigation_meta = #'#
    "<link rel=\"start\" href=\"http://" .
    $aid_util'config{'master_srv'} . #'#
    $aid_util'config{'master_path'} . #'#
    "\" title=\"" . $aid_util'config{'short_school'} . #'#
    " Alumni Internet Directory\"${ht_empty_close_tag}";

$aid_util'descr_meta = #'#
"<meta name=\"keywords\" content=\"" . $aid_util'config{'school'} . ", " .
$aid_util'config{'short_school'} . ", Anytown, California, reunion, alumni, directory\"${ht_empty_close_tag}\n<meta name=\"description\" content=\"Alumni e-mail and web page directory for " . $aid_util'config{'school'} . " in Anytown, CA. Updated __DATE__.\"${ht_empty_close_tag}"; #'#

$aid_util'disclaimer = #'#
"<a name=\"disclaimer\">Acceptable use:</a> the Alumni Internet
Directory is provided solely for the information of the
" . $aid_util'config{'school'} . " community.
Any redistribution outside of this community, or solicitation of
business or contributions from individuals listed in this publication is
forbidden.";

# colors
$aid_util'header_bg  = '99ccff'; #'#
$aid_util'header_fg  = '000000'; #'#

$aid_util'cell_bg    = 'eeeeee'; #'#
$aid_util'cell_fg    = '000000'; #'#

$aid_util'star_fg    = 'ff0000'; #'#

$aid_util'body_bg    = 'ffffff'; #'#
$aid_util'body_fg    = '000000'; #'#
$aid_util'body_link  = '0000cc'; #'#
$aid_util'body_vlink = '990099'; #'#

if ($^W && 0)
{
    $aid_util'disclaimer = '';
    $aid_util'author_meta = $aid_util'navigation_meta = $aid_util'descr_meta;

    $aid_util'header_bg  = $aid_util'header_fg  = '';
    $aid_util'cell_bg    = $aid_util'cell_fg  = '';
    $aid_util'star_fg    = ''; #'#
    $aid_util'body_bg    = $aid_util'body_fg =
	$aid_util'body_link  = $aid_util'body_vlink = ''; #'#
}

1;

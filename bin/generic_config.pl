#
#     FILE: awalt_config.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: configuration variables for Alumni Internet Directory
#      $Id: awalt_config.pl,v 1.7 1999/05/19 17:48:05 mradwin Exp $
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

$aid_util'rcsid =
 '$Id: awalt_config.pl,v 1.7 1999/05/19 17:48:05 mradwin Exp $';

# Generic HS on bogus-domain.org (FreeBSD 2.2.2) configuration
%aid_util'config =   #'#
    ('admin_name',   'Jane Smith',
     'admin_email',  "ghs-alumni-admin\@bogus-domain.org",
     'school',       'Generic High School',
     'short_school', 'GHS',
     'admin_school', "Generic High School, Class of '93",
     'admin_url',    'http://www.bogus-domain.org/~jsmith/',
     'master_srv',   'www.bogus-domain.org',
     'master_path',  '/ghs-alumni/',
     'search_cgi',   '/ghs-alumni/bin/nph-search',
     'vcard_cgi',    '/ghs-alumni/vcard',
     'goners_cgi',   '/ghs-alumni/bin/gone',
     'download_cgi', '/ghs-alumni/bin/alumni.txt',
     'go_cgi',       '/ghs-alumni/bin/go',
     'about_cgi',    '/ghs-alumni/bin/about',
     'submit_cgi',   '/ghs-alumni/bin/form/sub',
     'update_cgi',   '/ghs-alumni/bin/form/upd',
     'confirm_cgi',  '/ghs-alumni/bin/form/cnf',
     'yab_cgi',      '/ghs-alumni/bin/yab',
     'index_page',   'index.html',
     'cgidir',       '/home/jsmith/public_html/ghs-alumni/bin/',
     'wwwdir',       '/home/jsmith/public_html/ghs-alumni/',
     'dbmfile',      '/home/jsmith/public_html/ghs-alumni/master.db',
     'aiddir',       '/home/jsmith/ghs-alumni/',
     'sendmail',     '/usr/sbin/sendmail',
     'mailprog',     '/usr/bin/mail',
     'cat',          '/bin/cat',
     'cp',           '/bin/cp',
     'make',         '/usr/bin/make',
     'mailto',       "ghs-submissions\@bogus-domain.org",
     'mailsubj',     'GHSAID',
     'spoolfile',    '/var/mail/jsmith',
     'rcsid',        "$aid_util'rcsid",
     'sub_beg_str',  '_AID_BEGIN_SUBMISSION_',
     'sub_end_str',  '_AID_END_SUBMISSION_',
     'note_beg_str', '_AID_BEGIN_NOTE_',
     'note_end_str', '_AID_END_NOTE_',
     'html_ad', '',
     );

$aid_util'author_meta = #'#
"  <meta name=\"author\"  content=\"$aid_util'config{'admin_name'}\" />\n  <link rev=\"made\"     href=\"mailto:" . $aid_util'config{'admin_email'} . "\" />";

$aid_util'navigation_meta = #'#
    "  <link rel=\"contents\" href=\"http://" .
    $aid_util'config{'master_srv'} . #'#
    $aid_util'config{'master_path'} . #'#
    "\" title=\"Home page for " .
    $aid_util'config{'short_school'} . #'#
    " Alumni Internet Directory\" />";

$aid_util'descr_meta = #'#
"  <meta name=\"keywords\"    content=\"Generic High School, Anytown, California, reunion, alumni, directory\" />\n  <meta name=\"description\" content=\"Alumni e-mail and web page directory for Generic High School in Anytown, CA. Updated __DATE__.\" />";

$aid_util'disclaimer = #'#
"<a name=\"disclaimer\">Acceptable use:</a> the Alumni Internet
Directory is provided solely for the information of the Generic High
School community.  Any redistribution outside of this community, or
solicitation of business or contributions from individuals listed in
this publication is forbidden.";

# colors
$aid_util'header_bg  = '99ccff'; #'#
$aid_util'header_fg  = '000000'; #'#

$aid_util'cell_bg    = 'eeeeee'; #'#
$aid_util'star_fg    = 'ff0000'; #'#

$aid_util'body_bg    = 'ffffff'; #'#
$aid_util'body_fg    = '000000'; #'#
$aid_util'body_link  = '0000cc'; #'#
$aid_util'body_vlink = '990099'; #'#


if ($^W && 0)
{
    $aid_util'disclaimer = '';
    $aid_util'author_meta = $aid_util'navigation_meta = $aid_util'descr_meta;

    $aid_util'header_bg  = ''; #'#
    $aid_util'header_fg  = ''; #'#
    $aid_util'cell_bg    = ''; #'#
    $aid_util'star_fg    = ''; #'#
    $aid_util'body_bg    = ''; #'#
    $aid_util'body_fg    = ''; #'#
    $aid_util'body_link  = ''; #'#
    $aid_util'body_vlink = ''; #'#
}

1;

#
#     FILE: aid_config.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: configuration for Alumni Internet Directory
#      $Id: aid_config.pl,v 1.11 1999/03/17 18:14:15 mradwin Exp mradwin $
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

# radwin.org (FreeBSD 2.2.2) configuration
%aid_util'config =   #'#
    ('admin_name',   'Michael John Radwin',
     'admin_email',  "mvhs-alumni-admin\@radwin.org",
     'school',       'Mountain View High School',
     'short_school', 'MVHS',
     'admin_school', "Mountain View High School, Class of '93",
     'admin_phone',  '408-536-2554',
     'admin_url',    'http://www.radwin.org/michael/',
     'master_srv',   'www.radwin.org',
     'master_path',  '/mvhs-alumni/',
     'image_path',   '/images/',
     'search_cgi',   '/cgi-bin/nph-aid-search',
     'vcard_cgi',    '/mvhs-alumni/vcard',
     'goners_cgi',   '/cgi-bin/mvhsaid/gone',
     'download_cgi', '/cgi-bin/mvhsaid/alumni.txt',
     'go_cgi',       '/cgi-bin/mvhsaid/go',
     'about_cgi',    '/cgi-bin/mvhsaid/dyn',
     'submit_cgi',   '/cgi-bin/mvhsaid/sub',
     'update_cgi',   '/cgi-bin/mvhsaid/upd',
     'confirm_cgi',  '/cgi-bin/mvhsaid/cnf',
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
     'html_ad',
"<p>You might also be interested in joining the 
<a href=\"http://clubs.yahoo.com/clubs/mountainviewhighschool\">MVHS
Club on Yahoo!</a> The MVHS Club adds a Chat Room and Message Boards to
the services currently provided by this Directory.</p>

<p>Sign up for the 
<a href=\"http://www.planetall.com/main.asp?cid=1520098&gid=6602&s=40\">MVHS
Group on PlanetAll</a> if you want to share more detailed address book
information (birthdays, phone numbers, etc.) with other alumni.  People
will only be allowed to access your information with your permission,
and you can share as much or as little as you want.</p>
",
     );

@aid_util'MoY = #'#
    ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
$aid_util'caldate = &aid_caldate(time); #'#

$aid_util'site_tags = #'#
"  <meta name=\"keywords\"    content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">\n  <meta name=\"description\" content=\"Alumni e-mail and web page directory for Mountain View High School (MVHS) and Awalt High School in Mountain View, CA. Updated $aid_util'caldate.\">\n  <meta name=\"author\"  content=\"$aid_util'config{'admin_name'}\">\n  <link rev=\"made\"     href=\"mailto:" . $aid_util'config{'admin_email'} . "\">\n  <link rel=\"contents\" href=\"http://" . $aid_util'config{'master_srv'} . $aid_util'config{'master_path'} . "\" title=\"Home page for MVHS Alumni Internet Directory\">";

$aid_util'disclaimer = #'#
"<a name=\"disclaimer\">Acceptable use:</a> the Alumni Internet
Directory is provided solely for the information of the Mountain View
High School and Awalt High School communities.  Any redistribution
outside of this community, or solicitation of business or contributions
from individuals listed in this publication is forbidden.";

$aid_util'school_default    = 1; #'#
$aid_util'school_awalt      = 2; #'#
$aid_util'school_both       = 3; #'#

@aid_util'school_affil      = ('', '', 'A', 'A/MV');
@aid_util'school_name       = ('', 'MVHS', 'Awalt', 'Awalt/MV');

1;

#
#     FILE: aid_config.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: configuration variables for Alumni Internet Directory
#      $Id: aid_config.pl,v 1.19 1999/04/06 17:09:36 mradwin Exp mradwin $
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
 '$Id: aid_config.pl,v 1.19 1999/04/06 17:09:36 mradwin Exp mradwin $';

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
     'dbmfile',      '/home/web/radwin.org/docs/mvhs-alumni/master.db',
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
     'sub_beg_str',  '_AID_BEGIN_SUBMISSION_',
     'sub_end_str',  '_AID_END_SUBMISSION_',
     'note_beg_str', '_AID_BEGIN_NOTE_',
     'note_end_str', '_AID_END_NOTE_',
     'html_ad',
"
<h3>Want to network with other alumni?</h3>

<p>Sign up for the <a
href=\"http://www.planetall.com/main.asp?cid=1520098&gid=6602\">MVHS
Group on PlanetAll</a> or <a
href=\"http://www.planetall.com/main.asp?cid=1520098&gid=77847\">Awalt
Group on PlanetAll</a> if you want to share more detailed address book
information (birthdays, phone numbers, etc.) with other alumni.  People
will only be allowed to access your information with your permission,
and you can share as much or as little as you want.</p>

<p>You might also be interested in joining the 
<a href=\"http://clubs.yahoo.com/clubs/mountainviewhighschool\">MVHS
Club on Yahoo!</a> The MVHS Club adds a Chat Room and Message Boards to
the services currently provided by this Directory.</p>

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

# school name stuff
$aid_util'school_default    = 1; #'#
$aid_util'school_awalt      = 2; #'#
$aid_util'school_both       = 3; #'#

@aid_util'school_affil      = ('', '', 'A', 'A/MV');
@aid_util'school_name       = ('', 'MVHS', 'Awalt', 'Awalt/MV');

# colors
$aid_util'header_bg  = 'ffff99'; #'#
$aid_util'header_fg  = '000000'; #'#

$aid_util'cell_bg    = 'ffffcc'; #'#
$aid_util'star_fg    = 'ff0000'; #'#

$aid_util'body_bg    = 'ffffff'; #'#
$aid_util'body_fg    = '000000'; #'#
$aid_util'body_link  = '0000cc'; #'#
$aid_util'body_vlink = '990099'; #'#


@aid_util'req_descr_long =   #'#
    (
     'No e-mail except for bi-yearly address verification.',
     'All alumni, sorted by name. [~ 65 kbytes]',
     'All alumni, sorted by graduating class. [~ 65 kbytes]',
     'Only new and changed alumni entries. [~ 15 kbytes]',
     'Only people from my graduating class.',
     );

@aid_util'req_descr =   #'#
    (
     'only address verification',
     'yes (sorted by name)',
     'yes (sorted by graduating class)',
     'yes (new and changed entries)',
     'yes (just my graduating class)',
     );

@aid_util'page_idx = #'#
(
 "Home,"             . $aid_util'config{'master_path'},
 "Alpha,"            . $aid_util'config{'master_path'} . "alpha/a-index.html",
 "Class,"            . $aid_util'config{'master_path'} . "class/",
 "Awalt,"            . $aid_util'config{'master_path'} . "class/awalt.html",
 "Web&nbsp;Pages,"   . $aid_util'config{'master_path'} . "pages.html",
 "Recent,"           . $aid_util'config{'master_path'} . "recent.html",
 "Search,"           . $aid_util'config{'search_cgi'},
);

@aid_util'second_idx = #'#
(
 "Add/Update," . $aid_util'config{'master_path'} . "add/", #'#
 "Reunions,"   . $aid_util'config{'master_path'} . "etc/reunions.html", #'#
 "Links,"      . $aid_util'config{'master_path'} . "etc/links.html",    #'#
 "Download,"   . $aid_util'config{'master_path'} . "download/",        #'#
 "FAQ,"        . $aid_util'config{'master_path'} . "etc/faq.html",     #'#
 "Stats,"      . $aid_util'config{'master_path'} . "etc/stats.txt",    #'#
 "Privacy,"    . $aid_util'config{'master_path'} . "etc/copyright.html", #'#
);

$aid_util'pics_label = #'#
"  <meta http-equiv=\"PICS-Label\" content='(PICS-1.1 " . 
"\"http://www.rsac.org/ratingsv01.html\" l gen true " . 
"comment \"RSACi North America Server\" by \"" . 
$aid_util'config{'admin_email'} . 
"\" on \"1998.03.10T11:49-0800\" r (n 0 s 0 v 0 l 0))'>\n" .
"  <meta http-equiv=\"PICS-Label\" content='(PICS-1.1 " . 
"\"http://www.classify.org/safesurf/\" l gen true " .
"for \"http://" . $aid_util'config{'master_srv'} . "\" by \"" . 
$aid_util'config{'admin_email'} .
"\" r (SS~~000 1 SS~~100 1))'>"; #"#

$aid_util'noindex = "  <meta name=\"robots\"  content=\"noindex\">"; #'#
%aid_util'aid_aliases = ();   #'# global alias hash repository 

$aid_util'FIELD_SEP   = ";";   #'# character that separates fields in DB
$aid_util'ID_INDEX    = 0;     #'# position that the ID key is in datafile
@aid_util'field_names = #'# order is important!
    (
    'id',			# numerical userid
    'v',			# bit describing status
    'sn',			# last name
    'mn',			# married name
    'gn',			# first name
    'q',			# type of periodic emailing
    'r',			# bit for reunion email request
    'b',			# date of first bounce (0 if none)
    'c',			# date of record creation
    'u',			# date of last update
    'f',			# date of last successful verification
    's',			# high school (primary or Awalt)
    'yr',			# 4-digit grad year or affiliation
    'e',			# email address
    'w',			# personal web page
    'l',			# city, company, or college
    'h',			# REMOTE_HOST of last update
    'mi',			# middle initial
    'eu',		# date of last update to email
    'eo',		# previous email address
    );

%aid_util'field_descr = #'#
    (
    'id',	'[numerical userid]',
    'v',	'[valid bit describing status]',
    'sn',	'Last Name/Maiden Name',
    'mn',	'Married Last Name',
    'gn',	'First Name',
    'q',	'[type of quarterly emailing]',
    'r',	'[bit for reunion email request]',
    'b',	'[unix time - first bounce (0 if none)]',
    'c',	'[unix time - record creation]',
    'u',	'[unix time - last update]',
    'f',	'[unix time - last successful verification]',
    's',	'High School',
    'yr',	'Graduation Year or Affiliation',
    'e',	'E-mail Address',
    'w',	'Personal Web Page',
    'l',	'Location',
    'h',	'[REMOTE_HOST of last update]',
    'mi',	'Middle Initial',
    'eu',	'[unix time - last update to email]',
    'eo',	'Previous E-mail Address',
    );

$aid_util'pack_format = 'C3N5'; #'#
$aid_util'pack_len    = 23;     #'#

# ------------------------------------------------------------
# %aid_util'blank_entry -- a prototypical blank entry to clone
# ------------------------------------------------------------
%aid_util'blank_entry = ();
while (($key,$val) = each(%aid_util'field_descr))
{
    $aid_util'blank_entry{$key} = ''; #'#
}
undef($val);
$aid_util'blank_entry{'id'} = -1;      #'#
$aid_util'blank_entry{'v'}  = 1;       #'#
$aid_util'blank_entry{'q'}  = 4;       #'#
$aid_util'blank_entry{'r'}  = 1;       #'#
$aid_util'blank_entry{'b'}  = 0;       #'#
$aid_util'blank_entry{'eu'} = 0;       #'#
$aid_util'blank_entry{'eo'} = '';      #'#
$aid_util'blank_entry{'n'}  = '';      #'#
$aid_util'blank_entry{'s'}  = $aid_util'school_default;

%aid_util'image_tag = #'#
    (
    'new',
    "<small><strong class=\"newupd\">*NEW*</strong></small>",

    'new_anchored',
    "<small><strong class=\"newupd\">*NEW*</strong></small>",

    'updated',
    "<small><strong class=\"newupd\">*UPDATED*</strong></small>",

     'vcard',
     "<img src=\"" . $aid_util'config{'image_path'} . #'#
     "vcard.gif\" border=\"0\" align=\"top\" width=\"32\" height=\"32\" " .
     "alt=\"[vCard]\">",

     'info',
     "<img src=\"" . $aid_util'config{'master_path'} . #'#
     "info.gif\" border=\"0\" hspace=\"4\" width=\"12\" height=\"12\" " .
     "alt=\"[i]\">",

     'blank',
     "<img src=\"" . $aid_util'config{'master_path'} . #'#
     "blank.gif\" border=\"0\" hspace=\"4\" width=\"12\" height=\"12\" " .
     "alt=\"\">",
     );

sub aid_caldate
{
    package aid_util;

    local($[) = 0;
    local($time) = @_;
    local($i,$day,$month,$year);

    ($i,$i,$i,$day,$month,$year,$i,$i,$i) = localtime($time);
    sprintf("%02d-%s-%d", $day, $MoY[$month], ($year+1900));
}

# give 'em back the configuration variable they need
sub aid_config
{
    package aid_util;

    local($[) = 0;

    die "NO CONFIG $_[0]!\n" if !defined($config{$_[0]});
    $config{$_[0]};
}

# give 'em back the image_tag they need
sub aid_image_tag
{
    package aid_util;

    local($[) = 0;

    die "NO IMAGE_TAG $_[0]!\n" if !defined($image_tag{$_[0]});
    $image_tag{$_[0]};
}

if ($^W && 0)
{
    &aid_image_tag('');
    &aid_config('');
    $aid_util'disclaimer = '';
    $aid_util'site_tags = '';
    $aid_util'second_idx = ''; # line 150.
    $aid_util'school_awalt = ''; # line 102.
    $aid_util'page_idx = ''; # line 139.
    $aid_util'ID_INDEX = ''; # line 177.
    $aid_util'req_descr_long = ''; # line 121.
    $aid_util'FIELD_SEP = ''; # line 176.
    $aid_util'pics_label = ''; # line 161.
    $aid_util'body_vlink = ''; # line 118.
    $aid_util'school_both = ''; # line 103.
    $aid_util'body_bg = ''; # line 115.
    $aid_util'body_fg = ''; # line 116.
    $aid_util'pack_len = ''; # line 227.
    $aid_util'star_fg = ''; # line 113.
    $aid_util'pack_format = ''; # line 226.
    $aid_util'school_name = ''; # line 106.
    $aid_util'cell_bg = ''; # line 112.
    $aid_util'school_affil = ''; # line 105.
    $aid_util'aid_aliases = ''; # line 174.
    $aid_util'header_bg = ''; # line 109.
    $aid_util'header_fg = ''; # line 110.
    $aid_util'noindex = ''; # line 173.
    $aid_util'field_names = ''; # line 178.
    $aid_util'req_descr = ''; # line 130.
    $aid_util'body_link = ''; # line 117.
}

1;

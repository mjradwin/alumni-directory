#
#     FILE: aid_config.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: configuration variables for Alumni Internet Directory
#      $Id: aid_config.pl,v 1.44 1999/05/31 18:43:22 mradwin Exp mradwin $
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

@aid_util'MoY = #'#
    ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
$aid_util'caldate = &aid_caldate(time); #'#

if (defined $aid_util'descr_meta) #'#
{
    $aid_util'descr_meta =~ s/__DATE__/$aid_util'caldate/g;
}

@aid_util'req_descr_long =   #'#
    (
     'No thanks, just send me bi-yearly address verification messages.',
     'Yes, send me the entire Directory, sorted by name.',
     'Yes, send me the entire Directory, sorted by graduating class.',
     'Yes, send me a list of all new/updated alumni during the last quarter.',
     'Yes, send me a list of alumni from my graduating class.',
     );

@aid_util'req_descr =   #'#
    (
     'only address verification',
     'yes (entire Directory, sorted by name)',
     'yes (entire Directory, sorted by graduating class)',
     'yes (all new and updated alumni)',
     'yes (alumni from my graduating class)',
     );

die "NO CONFIG DEFINED!!\n" unless defined %aid_util'config; #'#

@aid_util'page_idx = #'#
(
 "Home,"             . $aid_util'config{'master_path'},
 "Alpha,"            . $aid_util'config{'master_path'} . "alpha/a-index.html",
 "Class,"            . $aid_util'config{'master_path'} . "class/",
 "MVHS,"             . "/mvhs-alumni/",
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
 "Stats,"      . $aid_util'config{'master_path'} . "etc/stats.html",    #'#
 "Privacy,"    . $aid_util'config{'master_path'} . "etc/privacy.html", #'#
);

$aid_util'copyright_path = $aid_util'config{'master_path'} .
    "etc/copyright.html";

$aid_util'pics_label = #'#
"  <meta http-equiv=\"PICS-Label\" content='(PICS-1.1 " . 
"\"http://www.rsac.org/ratingsv01.html\" l gen true " . 
"on \"1998.03.10T11:49-0800\" r (n 0 s 0 v 0 l 0))' />"; #"#

$aid_util'noindex = "  <meta name=\"robots\"  content=\"noindex\" />"; #'#
%aid_util'aid_aliases = ();   #'# global alias hash repository 

$aid_util'EPOCH       = 815130000; #'# Tue Oct 31 09:00:00 GMT 1995

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
    's',			# OBSOLETE
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

@aid_edit_field_names = # in the order we'd like to edit them
    (
     'id',
     'sn', 'gn', 'mi', 'mn',
     'e', 'a',
     'w', 'l',
     's', 'yr',
     'v', 'q', 'r',
     'c', 'u', 'f', 'b',
     'eu', 'eo',
     'h',
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
undef($key);

$aid_util'blank_entry{'id'} = -1;      #'#
$aid_util'blank_entry{'v'}  = 1;       #'#
$aid_util'blank_entry{'q'}  = 4;       #'#
$aid_util'blank_entry{'r'}  = 1;       #'#
$aid_util'blank_entry{'b'}  = 0;       #'#
$aid_util'blank_entry{'eu'} = 0;       #'#
$aid_util'blank_entry{'eo'} = '';      #'#
$aid_util'blank_entry{'n'}  = '';      #'#

%aid_util'image_tag = #'#
    (
     'new',
     "<strong class=\"nu\">*NEW*</strong>",

     'updated',
     "<strong class=\"nu\">*UPDATED*</strong>",

     'vcard',
     'View vCard',

     'info',
     "<strong class=\"i\">[i]</strong>",

     'blank',
     "<strong>&nbsp;&nbsp;&nbsp;</strong>",
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
    $aid_util'copyright_path = '';
    $aid_util'second_idx = ''; # line 150.
    $aid_util'page_idx = ''; # line 139.
    $aid_util'ID_INDEX = ''; # line 177.
    $aid_util'req_descr_long = ''; # line 121.
    $aid_util'FIELD_SEP = ''; # line 176.
    $aid_util'pics_label = ''; # line 161.
    $aid_util'pack_len = ''; # line 227.
    $aid_util'pack_format = ''; # line 226.
    $aid_util'aid_aliases = ''; # line 174.
    $aid_util'noindex = ''; # line 173.
    $aid_util'field_names = ''; # line 178.
    $aid_util'req_descr = ''; # line 130.
    @aid_edit_field_names = ();
    $aid_util'EPOCH       = '';
}

1;

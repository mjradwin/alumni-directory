#
#     FILE: aid_config.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: configuration variables for Alumni Internet Directory
#      $Id: aid_config.pl,v 5.6 1999/06/08 21:54:43 mradwin Exp mradwin $
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

%aid_util'parent_page_name = #'#
(
 '1',  'Alphabetically',
 '2',  'Graduating Classes',
# '12', 'Add/Update',
);

%aid_util'parent_page_path = #'#
(
 '1',  $aid_util'config{'master_path'} . 'alpha/', #'#
 '2',  $aid_util'config{'master_path'} . 'class/', #'#
# '12', $aid_util'config{'master_path'} . 'add/', #'#
);

$aid_util'copyright_path = $aid_util'config{'master_path'} .
    "etc/copyright.html";

$aid_util'pics_label = #'#
"<meta http-equiv=\"PICS-Label\" content='(PICS-1.1 " . 
"\"http://www.rsac.org/ratingsv01.html\" l gen true " . 
"on \"1998.03.10T11:49-0800\" r (n 0 s 0 v 0 l 0))'${ht_empty_close_tag}"; #"#

$aid_util'noindex = "<meta name=\"robots\" content=\"noindex\"${ht_empty_close_tag}"; #'#
%aid_util'aid_aliases = ();   #'# global alias hash repository 

$aid_util'EPOCH       = 815130000; #'# Tue Oct 31 09:00:00 GMT 1995

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
    's',	'[OBSOLETE - High School]',
    'yr',	'Graduation Year or Affiliation',
    'e',	'E-mail Address',
    'w',	'Personal Web Page',
    'l',	'Location',
    'h',	'[REMOTE_HOST of last update]',
    'mi',	'Middle Initial',
    'eu',	'[unix time - last update to email]',
    'eo',	'Previous E-mail Address',
    'a',	'[alias (a.k.a. nickname)]',
    'n',	'What\'s New? note',
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
%aid_util'blank_entry = (); #'#
foreach $key (@aid_edit_field_names)
{
    $aid_util'blank_entry{$key} = ''; #'#
}
undef($key);

$aid_util'blank_entry{'id'} = -1;      #'#
$aid_util'blank_entry{'v'}  = 1;       #'#
$aid_util'blank_entry{'q'}  = 4;       #'#
$aid_util'blank_entry{'r'}  = 1;       #'#
$aid_util'blank_entry{'b'}  = 0;       #'#
$aid_util'blank_entry{'eu'} = 0;       #'#
$aid_util'blank_entry{'n'}  = '';      #'#

%aid_util'image_tag = #'#
    (
     'new',
     "<b class=\"nu\">*NEW*</b>",

     'updated',
     "<b class=\"nu\">*UPDATED*</b>",

     'vcard',
     'View vCard',

     'info',
     "<b class=\"i\">[i]</b>",

     'blank',
     "<b>&nbsp;&nbsp;&nbsp;</b>",
     );

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
    @aid_util'second_idx = (); # line 150.
    @aid_util'page_idx = (); # line 139.
    @aid_util'req_descr_long = (); # line 121.
    $aid_util'pics_label = ''; # line 161.
    $aid_util'pack_len = ''; # line 227.
    $aid_util'pack_format = ''; # line 226.
    $aid_util'aid_aliases = ''; # line 174.
    $aid_util'noindex = ''; # line 173.
    @aid_util'req_descr = (); # line 130.
    @aid_edit_field_names = ();
    $aid_util'EPOCH       = '';
    %aid_util'field_descr = (); #'#
    %aid_util'parent_page_name = (); #'#
    %aid_util'parent_page_path = (); #'#
    $ht_empty_close_tag = '';
}

1;

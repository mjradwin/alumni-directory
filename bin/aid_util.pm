#
#     FILE: aid_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the Alumni Internet Directory
#      $Id: aid_util.pl,v 3.97 1999/01/22 21:10:18 mradwin Exp mradwin $
#

$aid_util'rcsid =
 '$Id: aid_util.pl,v 3.97 1999/01/22 21:10:18 mradwin Exp mradwin $';

# ----------------------------------------------------------------------
# CONFIGURATION
#
# to revise the AID for another school, you should edit the 
# *aid_util'variables in this configuration section, and the
# subroutines submit_body() and affiliate()
# ----------------------------------------------------------------------

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

@aid_util'req_descr_long =   #'#
    (
     'No e-mail except for yearly address verification.',
     'All alumni, sorted by name. [~ 50 kbytes]',
     'All alumni, sorted by graduating class. [~ 50 kbytes]',
     'Only new and changed alumni entries. [~ 10 kbytes]',
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
 "Alphabetically,"   . $aid_util'config{'master_path'} . "alpha/a-index.html",
 "Grad.&nbsp;Class," . $aid_util'config{'master_path'} . "class/",
 "Awalt,"            . $aid_util'config{'master_path'} . "class/awalt.html",
 "Web&nbsp;Pages,"   . $aid_util'config{'master_path'} . "pages.html",
 "Recent&nbsp;Additions," . $aid_util'config{'master_path'} . "recent.html",
);

@aid_util'second_idx = #'#
(
 "Add/Update," . $aid_util'config{'master_path'} . "add/", #'#
 "Reunions,"   . $aid_util'config{'master_path'} . "etc/reunions.html", #'#
 "Links,"      . $aid_util'config{'master_path'} . "etc/links.html",    #'#
 "Download,"   . $aid_util'config{'master_path'} . "download/",        #'#
 "FAQ,"        . $aid_util'config{'master_path'} . "etc/faq.html",     #'#
 "Stats,"      . $aid_util'config{'master_path'} . "etc/stats.txt",    #'#
 "Acceptable&nbsp;Use/Privacy,"
               . $aid_util'config{'master_path'} . "etc/copyright.html", #'#
);

@aid_util'MoY = #'#
    ('Jan','Feb','Mar','Apr','May','Jun',
     'Jul','Aug','Sep','Oct','Nov','Dec');

$aid_util'caldate = &aid_caldate(time); #'#

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

$aid_util'site_tags = #'#
"  <meta name=\"keywords\"    content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">\n  <meta name=\"description\" content=\"Alumni e-mail and web page directory for Mountain View High School (MVHS) and Awalt High School in Mountain View, CA. Updated $aid_util'caldate.\">\n  <meta name=\"author\"  content=\"$aid_util'config{'admin_name'}\">\n  <link rev=\"made\"     href=\"mailto:" . $aid_util'config{'admin_email'} . "\">\n  <link rel=\"contents\" href=\"http://" . $aid_util'config{'master_srv'} . $aid_util'config{'master_path'} . "\" title=\"Home page for MVHS Alumni Internet Directory\">";

$aid_util'noindex = "  <meta name=\"robots\"  content=\"noindex\">"; #'#
%aid_util'aid_aliases = ();   #'# global alias hash repository 

$aid_util'disclaimer = #'#
"<a name=\"disclaimer\">Acceptable use:</a> the Alumni Internet
Directory is provided solely for the information of the Mountain View
High School and Awalt High School communities.  Any redistribution
outside of this community, or solicitation of business or contributions
from individuals listed in this publication is forbidden.";

$aid_util'header_bg  = 'ffff99'; #'#
$aid_util'header_fg  = '000000'; #'#

$aid_util'cell_bg    = 'ffffcc'; #'#
$aid_util'cell_fg    = '000000'; #'#

$aid_util'star_fg    = 'ff0000'; #'#

$aid_util'body_bg    = 'ffffff'; #'#
$aid_util'body_fg    = '000000'; #'#
$aid_util'body_link  = '0000cc'; #'#
$aid_util'body_vlink = '990099'; #'#

$aid_util'FIELD_SEP   = ";";   #'# character that separates fields in DB
$aid_util'ID_INDEX    = 0;     #'# position that the ID key is in datafile
@aid_util'field_names = #'# order is important!
    (
    'id',			# numerical userid
    'valid',			# bit describing status
    'last',			# last name
    'married',			# married name
    'first',			# first name
    'request',			# type of periodic emailing
    'reunion',			# bit for reunion email request
    'bounce',			# date of first bounce (0 if none)
    'created',			# date of record creation
    'time',			# date of last update
    'fresh',			# date of last successful verification
    'school',			# high school (MVHS or Awalt)
    'year',			# 4-digit grad year or affiliation
    'email',			# email address
    'www',			# personal web page
    'location',			# city, company, or college
    'inethost',			# REMOTE_HOST of last update
    );

%aid_util'field_descr = #'#
    (
    'id',	'',
    'valid',	'',
    'last',	'Last Name/Maiden Name',
    'married',	'Married Last Name',
    'first',	'First Name',
    'request',	'',
    'reunion',	'',
    'bounce',	'',
    'created',	'',
    'time',	'',
    'fresh',	'',
    'school',	'High School',
    'year',	'Graduation year or affiliation',
    'email',	'E-mail address',
    'www',	'Personal Web Page',
    'location',	'Location',
    'inethost',	'',
    );

%aid_util'blank_entry =        #'# a prototypical blank entry to clone
    ();

for ($i = 0; $i <= $#aid_util'field_names; $i++) { #'#
     $aid_util'blank_entry{$aid_util'field_names[$i]} = '';
}

$aid_util'blank_entry{'id'}      = -1;      #'#
$aid_util'blank_entry{'valid'}   = 1;       #'#
$aid_util'blank_entry{'request'} = 4;       #'#
$aid_util'blank_entry{'reunion'} = 1;       #'#
$aid_util'blank_entry{'bounce'} = 0;       #'#
$aid_util'blank_entry{'message'} = '';      #'#
$aid_util'blank_entry{'school'}  = $aid_util'config{'short_school'};

%aid_util'image_tag = #'#
    (
     'new',
     "<img src=\"" . $aid_util'config{'master_path'} . #'#
     "new.gif\" border=0 width=28 height=10 " .
     "alt=\"[new]\">",
     
     'new_anchored',
     "<a href=\"" . $aid_util'config{'master_path'} . "recent.html\">" .
     "<img src=\"" . $aid_util'config{'master_path'} .
     "new.gif\" border=0 width=28 height=10 " .
     "alt=\"[new]\"></a>",

     'vcard',
     "<img src=\"" . $aid_util'config{'image_path'} . #'#
     "vcard.gif\" border=0 align=top width=32 height=32 " .
     "alt=\"[vCard]\">",

     'info',
     "<img src=\"" . $aid_util'config{'master_path'} . #'#
     "info.gif\" border=0 hspace=4 width=12 height=12 " .
     "alt=\"[i]\">",

     'blank',
     "<img src=\"" . $aid_util'config{'master_path'} . #'#
     "blank.gif\" border=0 hspace=4 width=12 height=12 " .
     "alt=\"\">",
     );

# ======================================================================


# give 'em back the configuration variable they need
sub aid_config {
    package aid_util;

    local($[) = 0;

    die "NO CONFIG $_[0]!\n" if !defined($config{$_[0]});
    $config{$_[0]};
}

# give 'em back the image_tag they need
sub aid_image_tag {
    package aid_util;

    local($[) = 0;

    die "NO IMAGE_TAG $_[0]!\n" if !defined($image_tag{$_[0]});
    $image_tag{$_[0]};
}

sub aid_caldate {
    package aid_util;

    local($[) = 0;
    local($time) = @_;
    local($i,$day,$month,$year);

    ($i,$i,$i,$day,$month,$year,$i,$i,$i) = localtime($time);
    sprintf("%02d-%s-%d", $day, $MoY[$month], ($year+1900));
}

sub aid_vdate {
    package aid_util;

    local($time) = @_;
    local($sec,$min,$hour,$i,$day,$month,$year);

    ($sec,$min,$hour,$day,$month,$year,$i,$i,$i) = gmtime($time);
    sprintf("%d%02d%02dT%02d%02d%02dZ", $year+1900, $month+1, $day,
	    $hour, $min, $sec);
}

# is the GMT less than one month ago?
# 2678400 = 31 days * 24 hrs * 60 mins * 60 secs
sub is_new {
    package aid_util;

    local($time,$months) = @_;

    $months = 1 unless $months;
    (((time - $time) < ($months * 2678400)) ? 1 : 0);
}


# is the GMT more than one year ago?
# 31536000 = 31 days * 24 hrs * 60 mins * 60 secs
sub is_old {
    package aid_util;

    local($[) = 0;

    (((time - $_[0]) >= 31536000) ? 1 : 0);
}


sub fullname {
    package aid_util;

    local(*rec) = @_;

    if ($rec{'first'} eq '') {
	$rec{'last'};
    } else {
	if ($rec{'married'} ne '') {
	    "$rec{'last'} (now $rec{'married'}), $rec{'first'}";
	} else {
	    "$rec{'last'}, $rec{'first'}";
	}
    }
}


sub inorder_fullname {
    package aid_util;

    local(*rec) = @_;

    if ($rec{'first'} eq '') {
	$rec{'last'};
    } else {
	if ($rec{'married'} ne '') {
	    "$rec{'first'} $rec{'last'} (now $rec{'married'})";
	} else {
	    "$rec{'first'} $rec{'last'}";
	}
    }
}


sub affiliate {
    package aid_util;

    local(*rec,$do_html_p) = @_;
    local($year,$affil,$len);

    $affil = '  ';
    $len   = 2;

    if ($rec{'year'} =~ /^\d+$/) {
	$affil .= "<a href=\"" . &main'aid_about_path(*rec,1) . "\">" #'#
	    if $do_html_p;
	$year = sprintf("%02d", $rec{'year'} % 100);
	if ($rec{'school'} eq 'Awalt') {
	    $affil  .= "A'$year";
	    $len    += length("A'$year");
	} elsif ($rec{'school'} eq $config{'short_school'} ||
		 $rec{'school'} eq '') {
	    $affil  .= "'$year";
	    $len    += length("'$year");
	} else {
	    $affil  .= "$rec{'school'} '$year";
	    $len    += length("$rec{'school'} '$year");
	}

	$affil .= "</a>" if $do_html_p;

    } else {
	$affil .= "<a href=\"" . &main'aid_about_path(*rec,1) . "\">" #'#
	    if $do_html_p;
	$affil .= "[$rec{'school'} $rec{'year'}]";
	$len   += length("[$rec{'school'} $rec{'year'}]");
	$affil .= "</a>" if $do_html_p;
    }

    ($affil,$len);
}


# remove punctuation, hyphens, parentheses, and quotes.
sub mangle {
    package aid_util;

    local($name) = @_;

    $name =~ s/\.//g;
    $name =~ s/\s//g;
    $name =~ s/\".*\"//g;
    $name =~ s/\(.*\)//g;
    $name =~ s/\'.*\'//g;

    $name;
}


sub aid_split {
    package aid_util;

    local($_) = @_;
    local($[) = 0;
    local(@fields) = defined $_ ? split(/$FIELD_SEP/) : ();
    local($i);
    local(%rec);

    for ($i = 0; $i <= $#field_names; $i++) {
	$rec{$field_names[$i]} = 
	    defined($fields[$i]) ? $fields[$i] : '';
    }

    %rec;
}


sub aid_join {
    package aid_util;

    local(*rec) = @_;
    local($[) = 0;
    local($i,@fields);

    for ($i = 0; $i <= $#field_names; $i++) {
	push(@fields, $rec{$field_names[$i]});
    }

    join($FIELD_SEP, @fields);
}


sub aid_parse {
    package aid_util;

    local($_) = @_;
    local(%rec) = &main'aid_split($_); #'#
    local($mangledLast,$mangledFirst,$alias);

    if ($rec{'valid'} == 0) {
	$rec{'alias'} = '';
	return %rec;
    }

    $mangledFirst = &main'mangle($rec{'first'}); #'#
    if ($rec{'married'} ne '') {
	$mangledLast = &main'mangle($rec{'married'});   #'#
    } else {
	$mangledLast = &main'mangle($rec{'last'});   #'#
    }

#    $alias = substr($mangledFirst, 0, 1) . substr($mangledLast, 0, 7);
    $alias = substr($mangledFirst, 0, 1) . $mangledLast;
    $alias = "\L$alias\E";

    if (defined($aid_aliases{$alias})) {
        $aid_aliases{$alias}++;
        $alias = substr($alias, 0, 7) . $aid_aliases{$alias};
    } else {
        $aid_aliases{$alias} = 1;
    }

    $rec{'alias'} = $alias;
    %rec;
}


sub aid_create_db {
    package aid_util;

    local($filename) = @_;
    local($[) = 0;
    local($_);
    local(@db,*INFILE);

    open(INFILE,$filename) || die "Can't open $filename: $!\n";
    while(<INFILE>) {
	chop;
	next unless defined $_ && $_ !~ /^\s*$/;
	$db[(split(/$FIELD_SEP/o))[$ID_INDEX]] = $_;
    }
    close(INFILE);
    
    @db;
}

sub aid_util'bydatakeys {   #'#
    package aid_util;

    $datakeys[$a] cmp $datakeys[$b];
}
 
sub aid_alpha_db {
    package aid_util;

    local($filename) = @_;
    local(@db) = &main'aid_create_db($filename);   #'#
    local(%rec);
    local($[) = 0;
    local($_);

    @datakeys = ();

    foreach (@db) {
	%rec = &main'aid_split($_);  #'#
	push(@datakeys, "\L$rec{'last'},$rec{'first'},$rec{'married'}\E");
    }

    @db[sort bydatakeys $[..$#db];
}

sub aid_class_db {
    package aid_util;

    local($filename) = @_;
    local(@db) = &main'aid_create_db($filename);   #'#
    local(%rec);
    local($[) = 0;
    local($_);

    @datakeys = ();

    foreach (@db) {
	%rec = &main'aid_split($_);  #'#
	push(@datakeys, "\L$rec{'year'},$rec{'last'},$rec{'first'},$rec{'married'}\E");
    }

    @db[sort bydatakeys $[..$#db];
}

sub aid_vcard_path {
    package aid_util;

    local($id) = @_;

    $config{'cgi_path'} . "/vcard/${id}.vcf";
}


sub aid_about_path {
    package aid_util;

    local(*rec,$suppress_anchor_p) = @_;
    local($page) = ($rec{'year'} =~ /^\d+$/) ? $rec{'year'} : 'other';
    local($anchor) = ($suppress_anchor_p) ? '' : "#id-$rec{'id'}";

    "$config{'master_path'}class/${page}.html${anchor}";
}


sub aid_newsfile {
    package aid_util;

    local($id) = @_;

    $config{'wwwdir'} . "whatsnew/${id}.txt";
}

sub aid_get_usertext {
    package aid_util;

    local($id) = @_;
    local($_);
    local($text,$inFile,*TEXTFILE);

    $text = '';
    $inFile = &main'aid_newsfile($id); #'#

    if (-r $inFile) {
	open(TEXTFILE,$inFile) || die "Can't open $inFile: $!\n";
	while(<TEXTFILE>) { $text .= $_; }
	close(TEXTFILE);
    }
    
    $text;
}

sub aid_html_escape {
    package aid_util;

    local($_) = @_;

    s/&/&amp;/g;
    s/</&lt;/g;
    s/>/&gt;/g;
    s/"/&quot;/g; #"#
    s/\s+/ /g;

    $_;
}

sub rec_html_entify {
    package aid_util;

    local(*rec_arg) = @_;
    local(%rec,$_);

    %rec = %rec_arg;

    foreach (keys %rec) {
	$rec{$_} =~ s/&/&amp;/g;
	$rec{$_} =~ s/</&lt;/g;
	$rec{$_} =~ s/>/&gt;/g;
	$rec{$_} =~ s/"/&quot;/g; #"#
	$rec{$_} =~ s/\s+/ /g unless $_ eq 'message';
    }

    %rec;
}

sub submit_body {
    package aid_util;

    local($[) = 0;
    local($_);
    local($body);
    local($star) = "<font color=\"#$star_fg\">*</font>";
    local(*rec_arg,$blank_entries) = @_;
    local(%rec) = &main'rec_html_entify(*rec_arg); #'#
    local($mvhs_checked,$awalt_checked,$other_checked) = ('', '', '');
    local(@reqchk,$i,$reunion_chk,@blankies);

    $rec{'www'} = 'http://' if $rec{'www'} eq '';

    for ($i = 0; $i < 5; $i++) {
	$reqchk[$i] = ($rec{'request'} == $i) ? ' checked' : '';
    }
    $reunion_chk = ($rec{'reunion'} == 1) ? ' checked' : '';

    if ($rec{'school'} eq $config{'short_school'} || 
	$rec{'school'} eq '') {
	$mvhs_checked = ' checked';
	$rec{'school'} = '';
    } elsif ($rec{'school'} eq 'Awalt') {
	$awalt_checked = ' checked';
	$rec{'school'} = '';
    } else {
	$other_checked = ' checked';
	$rec{'school'} = '' if $rec{'school'} eq 'Other';
    }

    $body = '';

    if ($blank_entries ne '')
    {
	if ($blank_entries =~ /email/ &&
	    $rec{'email'} ne '' && $rec{'email'} !~ /\@/)
	{
	    $body .= "<p><strong><font color=\"#$star_fg\">Your e-mail ";
	    $body .= "address appears to be missing a domain name.</font>\n";
	    $body .= "<br>It must be in the form of ";
	    $body .= "<code>user\@isp.net</code>.\n";
	    $body .= "Perhaps you meant to type ";
	    $body .= "<code>$rec{'email'}\@aol.com</code>?\n";
	    $body .= "</strong></p>\n\n";

	    $blank_entries =~ s/email//g;
	}

	@blankies = split(/\s+/, $blank_entries);
	if (@blankies)
	{
	    $body .= "<p><font color=\"#$star_fg\"><strong>It appears that ";
	    $body .= "the following required fields were blank:";
	    $body .= "</strong></font></p>\n\n<ul>\n";

	    foreach(@blankies)
	    {
		$body .= "<li>" . $field_descr{$_} . "\n";
	    }
	    $body .= "</ul>\n";
	}
    }

    $body .= "\n<p>Please ";
    $body .= (($rec{'id'} != -1) ? "update" : "enter");
    $body .= " the following information and hit the
<strong>Next&nbsp;&gt;</strong> button.</p>

<p>Fields marked with a $star
are required.  All other fields are optional.</p>\n\n";

    $body . "
<form method=post action=\"" . $config{'cgi_path'} . "/sub\"> 
<table border=0>
<tr><td align=right><input type=\"submit\" value=\"Next&nbsp;&gt;\">
&nbsp;
<input type=\"reset\" value=\"Start Over\">
</td></tr>
<tr><td>
<table border=0 width=\"100%\">
<tr><td bgcolor=\"#$cell_bg\"><table border=0 cellspacing=7>
<tr>
  <td valign=top><font color=\"#$cell_fg\"><label for=\"first\">First
  Name</label></font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"first\" size=35 
  value=\"$rec{'first'}\" id=\"first\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#$cell_fg\"><label for=\"last\">Last
  Name/Maiden Name</label></font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(your last name in high school)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"last\" size=35
  value=\"$rec{'last'}\" id=\"last\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#$cell_fg\"><label
  for=\"married\">Married Last Name</label></font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(if different from maiden name)</font></td>
  <td valign=top><input type=text name=\"married\" size=35
  value=\"$rec{'married'}\" id=\"married\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#$cell_fg\">High School</font></td>
  <td>$star</td>
  <td valign=top><input type=radio name=\"school\" id=\"school_$config{'short_school'}\"
  value=\"$config{'short_school'}\"$mvhs_checked><font color=\"#$cell_fg\"><label
  for=\"school_$config{'short_school'}\">&nbsp;$config{'short_school'}</label>&nbsp;&nbsp;&nbsp;&nbsp;<input id=\"school_Awalt\"
  type=radio name=\"school\" value=\"Awalt\"$awalt_checked><label
  for=\"school_Awalt\">&nbsp;Awalt</label></font></td>
</tr>
<tr>
  <td valign=top>&nbsp;</td>
  <td valign=top>&nbsp;</td>
  <td valign=top><input type=radio name=\"school\" id=\"school_Other\"
  value=\"Other\"$other_checked><font color=\"#$cell_fg\"><label
  for=\"school_Other\">&nbsp;Other:&nbsp;</label></font><input type=text
  name=\"sch_other\" size=27 value=\"$rec{'school'}\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#$cell_fg\"><label
  for=\"year\">Graduation year or affiliation</label></font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(such as 1993, 2001, or Teacher)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"year\" size=35
  value=\"$rec{'year'}\" id=\"year\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#$cell_fg\"><label
  for=\"email\">E-mail address</label></font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(such as chester\@aol.com)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"email\" size=35
  value=\"$rec{'email'}\" id=\"email\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#$cell_fg\"><label
  for=\"www\">Personal Web Page</label></font></td>
  <td valign=top><input type=text name=\"www\" size=35
  value=\"$rec{'www'}\" id=\"www\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#$cell_fg\"><label
  for=\"location\">Location</label></font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(your city, school, or company)</font></td>
  <td valign=top><input type=text name=\"location\" size=35
  value=\"$rec{'location'}\" id=\"location\"></td>
</tr>
<tr>
  <td colspan=3><font color=\"#$cell_fg\">
  <br><label for=\"message\"><strong>What's New?</strong>
  Let your classmates know what you've been doing since<br>graduation,
  or any important bits of news you'd like to share.</label></font><br>
  <textarea name=\"message\" rows=10 cols=55 wrap=hard
  id=\"message\">$rec{'message'}</textarea>
  </td>
</tr>
<tr>
  <td colspan=3><font color=\"#$cell_fg\" size=\"-1\"><input type=checkbox
  name=\"reunion\" id=\"reunion\" $reunion_chk><label
  for=\"reunion\">&nbsp;My class officers may notify me of
  reunion information via e-mail.</label><br><br>Please 
  <a href=\"" . $config{'master_path'} . "etc/faq.html#mailings\">send 
  an updated copy</a> of the Directory to my e-mail address<br>
  every February, May, August and November:<br>

  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request4\"
  value=\"4\"$reqchk[4]><label for=\"request4\">&nbsp;
  $req_descr_long[4]</label><br>

  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request3\"
  value=\"3\"$reqchk[3]><label for=\"request3\">&nbsp;
  $req_descr_long[3]</label><br>

  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request2\"
  value=\"2\"$reqchk[2]><label for=\"request2\">&nbsp;
  $req_descr_long[2]</label><br>

  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request1\"
  value=\"1\"$reqchk[1]><label for=\"request1\">&nbsp;
  $req_descr_long[1]</label><br>

  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request0\"
  value=\"0\"$reqchk[0]><label for=\"request0\">&nbsp;
  $req_descr_long[0]</label></font>

  <input type=\"hidden\" name=\"id\" value=\"$rec{'id'}\">
  <input type=\"hidden\" name=\"created\" value=\"$rec{'created'}\">
  <input type=\"hidden\" name=\"valid\" value=\"1\">
  </td>
</tr>
</table>
</td></tr></table></td></tr>
<tr><td align=right><input type=\"submit\" value=\"Next&nbsp;&gt;\">
&nbsp;
<input type=\"reset\" value=\"Start Over\">
</td></tr>
</table>
</form>

";

}


sub sendmail {
    package aid_util;

    local($to,$return_path,$from,$subject,$body) = @_;
    local(*F);
    local($toline,$header);

    $to =~ s/\s*\([^\)]*\)\s*//;
    $toline = join(', ', split(/[ \t]+/, $to));
    $header =
"From: $from <$return_path>\
To: $toline\
X-Sender: $return_path\
X-Mailer: $config{'short_school'} Alumni Internet Directory mailer\
Organization: $config{'school'} Alumni Internet Directory\
Precedence: bulk\
Content-Type: text/plain; charset=ISO-8859-1\
Content-Transfer-Encoding: 8bit\
Subject: $subject\
";

    if (open(F, "| $config{'sendmail'} -R hdrs $to")) {
	print F $header;
	print F $body;
	close(F);

    } else {
	warn "cannot send mail: $!\n";
    }
}


sub message_footer {
    package aid_util;

    "\n--\n" .	$config{'admin_name'} . "\n" . $config{'admin_school'};
}

sub aid_verbose_entry {
    package aid_util;

    local(*rec_arg,$display_year,$suppress_new) = @_;
    local($_);
    local($fullname);
    local(*rec);
    local($retval) = '';

    $rec_arg{'message'} = &main'aid_get_usertext($rec_arg{'id'}); #'#
    %rec = &main'rec_html_entify(*rec_arg);

    $fullname = &main'inorder_fullname(*rec); #'#

    $retval .= "<dl compact>\n";

    $retval .= "<dt><font size=\"+1\">";
    $retval .= "<strong>";
    $retval .= "<a name=\"id-$rec{'id'}\">";
    $retval .=  $fullname;
    $retval .= "</a>";
    $retval .= "</strong>";
    $retval .= "</font>\n";

    $retval .= "&nbsp;<font size=\"-1\">[";
    $retval .= "<a href=\"" . &main'aid_vcard_path($rec{'id'}) . "\">"; #'#
    $retval .= "vCard</a>";
    $retval .= "&nbsp;|&nbsp;";
    $retval .= "<a href=\"" . $config{'cgi_path'} . "/dyn?about=$rec{'id'}\">";
    $retval .= "update</a>";
    $retval .= "]</font>\n";
    
    $retval .= $image_tag{'new_anchored'}
	if !$suppress_new && &main'is_new($rec{'time'});  #'#

    $retval .= "</dt>\n";
    $retval .= "<dt>School: <strong>$rec{'school'}</strong></dt>\n" 
	if $rec{'school'} ne $config{'short_school'};

    if ($rec{'year'} =~ /^\d+$/) {
	if ($display_year) {
	    $retval .= "<dt>Year:  <strong>";
	    $retval .= 
		"<a href=\"" . &main'aid_about_path(*rec,1) . "\">"; #'#
	    $retval .= $rec{'year'};
	    $retval .= "</a></strong></dt>\n";
	}
    } else {
	$retval .= "<dt>Affiliation:  <strong>";
	$retval .= "<a href=\"" . &main'aid_about_path(*rec,1) . "\">"; #'#
	$retval .= $rec{'year'};
	$retval .= "</a></strong></dt>\n";
    }

    $retval .= "<dt>E-mail: <code><strong><a href=\"mailto:$rec{'email'}\">";
    $retval .= $rec{'email'};
    $retval .= "</a></strong></code></dt>\n";
    $retval .= "<dt>Web Page: <code><strong><a href=\"$rec{'www'}\">$rec{'www'}</a></strong></code></dt>\n"
	if $rec{'www'} ne '';
    $retval .= "<dt>Location: <strong>$rec{'location'}</strong></dt>\n"
	if $rec{'location'} ne '';
    $retval .= "<dt>Updated: ";
    $date = &main'aid_caldate($rec{'time'}); #'#
    $retval .= "<strong>$date</strong></dt>\n";

    if ($rec{'message'} ne '') {
	$retval .= "<dt>What's New?</dt>\n";
	$rec{'message'} =~ s/\n/<br>\n/g;
	$retval .= "<dd>$rec{'message'}</dd>\n";
    }
    $retval .= "</dl>\n\n";

    $retval;
}


sub aid_vcard_text {
    package aid_util;

    local(*rec) = @_;
    local($v_fn,$v_n,$retval);

    if ($rec{'married'} ne '') {
	$v_n  = "N:$rec{'married'};$rec{'first'};$rec{'last'}\r\n";
	$v_fn = "FN:$rec{'first'} $rec{'last'} $rec{'married'}\r\n";
    } else {
	$v_n  = "N:$rec{'last'};$rec{'first'}\r\n";
	$v_fn = "FN:$rec{'first'} $rec{'last'}\r\n";
    }

    $retval  = "Begin:vCard\r\n";
    $retval .= $v_n;
    $retval .= $v_fn;
    $retval .= "ORG:$rec{'school'};";
    if ($rec{'year'} =~ /^\d+$/) {
	$retval .= "Class of $rec{'year'}\r\n";
    } else {
	$retval .= "$rec{'year'}\r\n";
    }
    $retval .= "EMAIL;PREF;INTERNET:$rec{'email'}\r\n";
    if ($rec{'location'} =~ /^(.*),\s+(\w\w)$/) {
	$retval .= "ADR:;;;$1;\U$2\E\r\n";
    } else {
	$retval .= "ADR:;;;$rec{'location'}\r\n" if $rec{'location'} ne '';
    }
    $retval .= "URL:$rec{'www'}\r\n" if $rec{'www'} ne '';
    $retval .= "REV:" . &main'aid_vdate($rec{'time'}) . "\r\n"; #'#
    $retval .= "End:vCard\r\n";

    $retval;
}


sub about_text {
    package aid_util;

    local($retval) = '';
    local(*rec_arg,$show_req_p,$do_html_p,$do_vcard_p) = @_;
    local(%rec) = $do_html_p ? &main'rec_html_entify(*rec_arg) : %rec_arg; #'#

    $do_vcard_p = 0 unless defined($do_vcard_p);

    $retval .= "<table border=0 cellpadding=6><tr><td bgcolor=\"#$cell_bg\"><font color=\"#$cell_fg\"><pre>\n\n" if $do_html_p;

    $retval .= "First Name         : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $rec{'first'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Last/Maiden Name   : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $rec{'last'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Married Last Name  : ";
    if ($rec{'married'} eq '') {
	$retval .= "(same as last name)";
    } else {
	$retval .= "<strong>" if $do_html_p;
	$retval .= $rec{'married'};
	$retval .= "</strong>" if $do_html_p;
    }
    $retval .= "\n";
    
    $retval .= "\n";
    $retval .= "School             : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $rec{'school'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    if ($rec{'year'} =~ /^\d+$/) {
	$retval .= "Grad. Year         : ";
    } else {
	$retval .= "Affiliation        : ";
    }
    $retval .= "<strong>" if $do_html_p;
    $retval .= "<a href=\"" . &main'aid_about_path(*rec) . "\">" #'#
	    if $do_html_p && !$show_req_p;
    $retval .= $rec{'year'};
    $retval .= "</a>" if $do_html_p && !$show_req_p;
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";

    $retval .= "\n";
    $retval .= "E-mail             : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= "<a href=\"mailto:$rec{'email'}\">"
	if $do_html_p && !$show_req_p;
    $retval .= $rec{'email'};
    $retval .= "</a>" if $do_html_p && !$show_req_p;
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";

    $retval .= "Personal Web Page  : ";
    $retval .= ($rec{'www'} eq '') ? "(none)\n" :
	((($do_html_p) ? "<strong><a href=\"$rec{'www'}\">" : "") .
	 $rec{'www'} . 
	 (($do_html_p) ? "</a></strong>" : "") .
	 "\n");

    $retval .= "Location           : ";
    $retval .= ($rec{'location'} eq '') ? "(none)\n" :
	((($do_html_p) ? "<strong>" : "") .
	 $rec{'location'} .
	 (($do_html_p) ? "</strong>" : "") .
	 "\n");

    if ($do_vcard_p && $do_html_p) {
	$retval .= "vCard              : ";
	$retval .= "<a href=\"" . &main'aid_vcard_path($rec{'id'}) . "\">"; #'#
	$retval .= $image_tag{'vcard'};
	$retval .= "</a>\n";
    }

    if ($show_req_p) {
	$retval .= "\n";
	$retval .= "Reunion Info Okay  : ";
	$retval .= ($rec{'reunion'} == 1) ?
	    "yes\n" : "no\n";
	$retval .= "Send E-mail Updates: ";
	$retval .= defined $req_descr[$rec{'request'}] ?
	    "$req_descr[$rec{'request'}]\n" : "(unknown)\n";
    } 

    if ($rec{'time'} ne '' && $rec{'time'} != 0 &&
	$rec{'created'} ne '' && $rec{'created'} != 0) {
	$retval .= "\n";
	$retval .= "Joined Directory   : ";
        $retval .= &main'aid_caldate($rec{'created'}) . "\n"; #'#
    }

    if ($rec{'time'} ne '' && $rec{'time'} != 0) {
	$retval .= "Last Updated       : ";
	$retval .= &main'aid_caldate($rec{'time'}) . "\n"; #'#
    }

    $rec{'message'} = &main'aid_get_usertext($rec{'id'}) #'#
	unless defined($rec{'message'});

    if ($rec{'message'} ne '') {
	$retval .= "\n";
	$retval .= "What's New?        :\n";
	$retval .= "</pre>\n" if $do_html_p;
	$retval .= $do_html_p ? "<blockquote>\n" : "";
	$rec{'message'} =~ s/\n/<br>\n/g if $do_html_p;
	$retval .= $rec{'message'};
	$retval .= $do_html_p ? "</blockquote>\n" : "";
    } else {
	$retval .= "\n";
	$retval .= "What's New?        : (blank)\n";
	$retval .= "</pre>\n" if $do_html_p;
    }

    $retval .= "</font></td></tr></table>\n" if $do_html_p;

    $retval;
}

sub common_intro_para {
    package aid_util;

    local($[) = 0;
    local($new) = "<p>Any entries marked with\n" . $image_tag{'new'} .
	"\nhave been added to the Directory within the last month.\n";
    local($info) = "The " . $image_tag{'info'} .
	"\nicon lets you get more detailed information about an alumnus.";
    local($end) = "</p>\n\n";

    $new . ($_[0] ? $info : '') . $end;
}

sub common_link_table {
    package aid_util;

    local($[) = 0;
    local($page) = @_;
    local($html,$name,$url,$idx);

    $html  = "<!-- begin common_link_table -->\n";
    $html .= "<p align=center><font size=\"-1\">";

    foreach $idx (0 .. $#page_idx) {
	($name, $url) = split(/,/, $page_idx[$idx]);
        if ($idx == $page) {
	    $html .= "\n  <strong>$name</strong>";
        } else {
            $html .= "<a\n  href=\"$url\">$name</a>";
        }
	$html .= " || " unless $idx == $#page_idx;
    }
    $html .= "\n  <br>";
    foreach $idx (0 .. $#second_idx) {
	($name, $url) = split(/,/, $second_idx[$idx]);
        if ($idx == ($page - 10)) {
	    $html .= "\n  <strong>$name</strong>";
        } else {
            $html .= "<a\n  href=\"$url\">$name</a>";
        }
	$html .= " || " unless $idx == $#second_idx;
    }
    $html .= "\n</font></p>\n";
    $html .= "<!-- end common_link_table -->\n";
    
    $html;
}


sub common_html_ftr {
    package aid_util;

    local($[) = 0;
    local($page) = @_;
    local($ftr,$copyright);

    $copyright = $second_idx[5];
    $copyright =~ s/^[^,]+,//;

    $ftr  = "\n<!-- begin common_html_ftr -->\n";
#    $ftr .= "<table cellspacing=0 cellpadding=6 border=1 width=\"100%\">\n" .
#	"  <tr>\n    <td bgcolor=\"#$cell_bg\" valign=middle>\n";
    $ftr .= "<hr noshade size=\"1\">\n";
#    $ftr .= &main'common_link_table($page); #'#
    $ftr .= "\n<font size=\"-1\">" . $disclaimer . "</font><br>\n\n";
#    $ftr .= "    </td>\n  </tr>\n</table>\n";

    $ftr .= "\n<br><font size=\"-1\"><a href=\"" . $copyright . "\">" .
	"Copyright\n&copy; 1999 " . $config{'admin_name'} . "</a></font>\n\n" .
	"<!-- end common_html_ftr -->\n\n</body>\n</html>\n";

    $ftr;
}


sub common_html_hdr {
    require 'ctime.pl';
    require 'tableheader.pl';
    package aid_util;

    local($page,$title,$norobots) = @_;
    local($hdr,$tablehdr,$timestamp,$titletag);
    local($date) = &main'ctime(time);  #'#

    chop $date;
    $timestamp = (($page == 0) ? 'Last update to Directory: ' :
		  'Last update to this page: ') . $date;

    $tablehdr = $title eq '' ? '' :
	"    <!-- \"$title\" -->\n    <strong>" .
	&main'tableheader_internal($title,1,$header_fg) . #'#
	    "</strong>\n\n";

    $titletag = ($page == 0) ?
	($config{'school'} . " Alumni Internet Directory") :
	($config{'short_school'} . " Alumni: " . $title);

    $hdr  = 
	"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n" .
	"        \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n" .
	"<!--  " . $config{'rcsid'} . " -->\n" .
	"<html>\n<head>\n" .
	"  <title>" . $titletag . "</title>\n" . 
	    $pics_label . "\n" . $site_tags . "\n";
    $hdr .= "$noindex\n" if $norobots;
    $hdr .= "</head>\n\n";
    
    $hdr .= "<!-- begin common_html_hdr -->\n";

    $hdr .= "<body bgcolor=\"#$body_bg\" text=\"#$body_fg\" link=\"#$body_link\" vlink=\"#$body_vlink\">\n";
    
    $hdr .= "
<center>
<table cellspacing=0 cellpadding=6 border=0 width=\"100%\">
  <tr>
    <td bgcolor=\"#$header_bg\" valign=middle><p align=left><font size=\"+2\"
    color=\"#$header_fg\"><strong><code>$config{'school'} Alumni
    Internet Directory</code></strong></font>
    </p><p align=right><font size=\"-1\" 
    color=\"#$header_fg\"><em>$timestamp</em></font></p>
    </td>
  </tr>
  <tr>
    <td bgcolor=\"#$cell_bg\" align=center valign=middle>
$tablehdr";
    $hdr .= &main'common_link_table($page); #'#
    $hdr .= "    </td>
  </tr>
</table>
</center>

<!-- discourage www.roverbot.com -->
<!--BAD-DOG-->

";

    $hdr .= "<!-- end common_html_hdr -->\n\n";

    $hdr;
}

sub aid_build_yearlist {
    package aid_util;

    local($[) = 0;
    local(*years,$year) = @_;

    if ($years[$#years] ne $year && $years[$#years] ne 'other') {
	push(@years, ($year =~ /^\d+$/) ? $year : 'other');
    }

    1;
}

sub aid_class_jump_bar {
    package aid_util;

    local($href_begin,$href_end,*years,$do_paragraph,$hilite) = @_;
    local($first) = 1;
    local($retval) = $do_paragraph ? '<p>' : '';
    local($year);

    foreach $year (@years) {
	if ($first) {
	    $retval .= "<a name=\"top\"";
	    $retval .= ">" if defined $hilite && $year eq $hilite;
	} else {
	    $retval .= " |\n";
	    $retval .= "<a" unless defined $hilite && $year eq $hilite;
	}

	$retval .= " href=\"${href_begin}${year}${href_end}\">"
	    unless defined $hilite && $year eq $hilite;
	$retval .= ($year eq 'other') ? "Faculty/Staff" :
	    sprintf("%02d", $year % 100);
	$retval .= "</a>"
	    unless defined $hilite && $year eq $hilite && !$first;

	$first = 0;
    }

    $do_paragraph && $retval .= '</p>';
    $retval .= "\n\n";

    $retval;
}



sub aid_book_write_prefix {
    package aid_util;

    local(*BOOK,$option) = @_;
    local($school) = &main'aid_config('school'); #'#

    # special case for netscape
    if ($option eq 'n') {
	print BOOK "<!DOCTYPE NETSCAPE-Addressbook-file-1>
<!-- This is an automatically generated file.
It will be read and overwritten.
Do Not Edit! -->
<TITLE>$school Alumni Address book</TITLE>
<H1>$school Alumni Address book</H1>

<DL><p>\n";
    }

    elsif ($option eq 'o') {
	print BOOK
	    "\"Title\",\"First Name\",\"Middle Name\",\"Last Name\",\"Suffix\",\"Company\",\"Department\",\"Job Title\",\"Business Street\",\"Business Street 2\",\"Business Street 3\",\"Business City\",\"Business State\",\"Business Postal Code\",\"Business Country\",\"Home Street\",\"Home Street 2\",\"Home Street 3\",\"Home City\",\"Home State\",\"Home Postal Code\",\"Home Country\",\"Other Street\",\"Other Street 2\",\"Other Street 3\",\"Other City\",\"Other State\",\"Other Postal Code\",\"Other Country\",\"Assistant's Phone\",\"Business Fax\",\"Business Phone\",\"Business Phone 2\",\"Callback\",\"Car Phone\",\"Company Main Phone\",\"Home Fax\",\"Home Phone\",\"Home Phone 2\",\"ISDN\",\"Mobile Phone\",\"Other Fax\",\"Other Phone\",\"Pager\",\"Primary Phone\",\"Radio Phone\",\"TTY/TDD Phone\",\"Telex\",\"Account\",\"Anniversary\",\"Assistant's Name\",\"Billing Information\",\"Birthday\",\"Categories\",\"Children\",\"E-mail Address\",\"E-mail Display Name\",\"E-mail 2 Address\",\"E-mail 2 Display Name\",\"E-mail 3 Address\",\"E-mail 3 Display Name\",\"Gender\",\"Government ID Number\",\"Hobby\",\"Initials\",\"Keywords\",\"Language\",\"Location\",\"Mileage\",\"Notes\",\"Office Location\",\"Organizational ID Number\",\"PO Box\",\"Private\",\"Profession\",\"Referred By\",\"Spouse\",\"User 1\",\"User 2\",\"User 3\",\"User 4\",\"Web Page\"\r\n";
    }
}

sub aid_book_write_entry {
    package aid_util;

    local(*BOOK,$option,*rec) = @_;
    local($long_last) = $rec{'last'};

    $long_last .= " $rec{'married'}" if $rec{'married'} ne '';

    $option eq 'p' && print BOOK "$rec{'alias'}\t$long_last, $rec{'first'}\t$rec{'email'}\t\t$rec{'school'} $rec{'year'}\n";
    $option eq 'e' && print BOOK "$rec{'alias'} = $long_last; $rec{'first'}, $rec{'school'} $rec{'year'} = $rec{'email'}\n";
    $option eq 'b' && print BOOK "alias $rec{'alias'}\t$rec{'email'}\n";
    $option eq 'w' && print BOOK "<$rec{'alias'}>\r\n>$rec{'first'} $long_last <$rec{'email'}>\r\n<$rec{'alias'}>\r\n>$rec{'school'} $rec{'year'}\r\n";
    $option eq 'm' && print BOOK "alias $rec{'alias'} $rec{'email'}\r\nnote $rec{'alias'} <name:$rec{'first'} $long_last>$rec{'school'} $rec{'year'}\r\n";

    # netscape is a bigger sucker
    if ($option eq 'n') {
	print BOOK "    <DT><A HREF=\"mailto:$rec{'email'}\" ";
	print BOOK "NICKNAME=\"$rec{'alias'}\">$rec{'first'} $long_last</A>\n";
	print BOOK "<DD>$rec{'school'} $rec{'year'}\n";
    }

    elsif ($option eq 'l') {
        print BOOK "dn: cn=$rec{'first'} $long_last,mail=$rec{'email'}\r\n";
	print BOOK "modifytimestamp: ";
	$vdate = &main'aid_vdate($rec{'time'}); #'#
	$vdate =~ s/T//;
	print BOOK "$vdate\r\n";
        print BOOK "cn: $rec{'first'} $long_last\r\n";
	if ($rec{'married'} ne '') {
	    print BOOK "sn: $rec{'married'}\r\n";
	} else {
	    print BOOK "sn: $rec{'last'}\r\n";
	}
        print BOOK "givenname: $rec{'first'}\r\n";
        print BOOK "objectclass: top\r\nobjectclass: person\r\n";
        print BOOK "mail: $rec{'email'}\r\n";
	if ($rec{'location'} =~ /^(.*),\s+(\w\w)$/) {
	    print BOOK "locality: $1\r\n";
	    print BOOK "st: $2\r\n";
	} else {
	    print BOOK "locality: $rec{'location'}\r\n" if $rec{'location'} ne '';
	}
        print BOOK "o: $rec{'school'}\r\n";
	if ($rec{'year'} =~ /^\d+$/) {
	    print BOOK "ou: Class of $rec{'year'}\r\n";
	} else {
	    print BOOK "ou: $rec{'year'}\r\n";
	}
        print BOOK "homeurl: $rec{'www'}\r\n" if $rec{'www'} ne '';
        print BOOK "xmozillanickname: $rec{'alias'}\r\n";
        print BOOK "\r\n";
    }
    
    # lots of data for a vCard
    elsif ($option eq 'v') {
	print BOOK &main'aid_vcard_text(*rec), "\r\n"; #'#
    }

    elsif ($option eq 'o') {
	print BOOK "\"\",\"$rec{'first'}\",";
	if ($rec{'married'} ne '') {
	    print BOOK "\"$rec{'last'}\",\"$rec{'married'}\",";
	} else {
	    print BOOK "\"\",\"$rec{'last'}\",";
	}

	print BOOK "\"\",\"$rec{'school'} $rec{'year'}\",\"\",";
#	print BOOK "\"\",\"$rec{'school'}\",";
#	if ($rec{'year'} =~ /^\d+$/) {
#	    print BOOK "\"Class of $rec{'year'}\",";
#	} else {
#	    print BOOK "\"$rec{'year'}\",";
#	}

	print BOOK "\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",";

	if ($rec{'location'} =~ /^(.*),\s+(\w\w)$/) {
	    print BOOK "\"$1\",\"$2\",";
	} else {
	    print BOOK "\"$rec{'location'}\",\"\",";
	}

	print BOOK "\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"MVHS Alumni\",\"\",\"$rec{'email'}\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"$rec{'www'}\"\r\n";
    }
}

sub aid_book_write_suffix {
    package aid_util;

    local(*BOOK,$option) = @_;

    $option eq 'n' && print BOOK "</DL><p>\n";
}


1;

#
#     FILE: aid_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the Alumni Internet Directory
#      $Id: aid_util.pl,v 3.68 1998/10/27 19:09:19 mradwin Exp mradwin $
#

$aid_util'rcsid =
 '$Id: aid_util.pl,v 3.68 1998/10/27 19:09:19 mradwin Exp mradwin $';

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
     'echo',         '/bin/echo',
     'cat',          '/bin/cat',
     'cp',           '/bin/cp',
     'make',         '/usr/bin/make',
     'mailto',       "mvhs-submissions\@radwin.org",
     'mailsubj',     'MVHSAID',
     'spoolfile',    '/var/mail/mradwin',
     'rcsid',        "$aid_util'rcsid",
     );

@aid_util'page_idx = #'#
    (
     "Home,"                  . $aid_util'config{'master_path'},                 #'#
     "Alphabetically,"        . $aid_util'config{'master_path'} . "alpha/a-index.html",    #'#
     "Grad.&nbsp;Class,"      . $aid_util'config{'master_path'} . "class/",      #'#
     "Awalt&nbsp;Alumni,"     . $aid_util'config{'master_path'} . "class/awalt.html",  #'#
     "Web&nbsp;Pages,"        . $aid_util'config{'master_path'} . "pages.html",  #'#
     "Recent&nbsp;Additions," . $aid_util'config{'master_path'} . "recent.html", #'#
     );

@aid_util'second_idx = #'#
    (
     "Add/Update,"          . $aid_util'config{'master_path'} . "add/", #'#
     "Reunions,"            . $aid_util'config{'master_path'} . "etc/reunions.html", #'#
     "Links,"               . $aid_util'config{'master_path'} . "etc/links.html",    #'#
     "Download,"            . $aid_util'config{'master_path'} . "books/",        #'#
     "FAQ,"                 . $aid_util'config{'master_path'} . "etc/faq.html",     #'#
     "Acceptable&nbsp;Use," . $aid_util'config{'master_path'} . "etc/copyright.html", #'#
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
"  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=ISO-8859-1\">\n  <meta name=\"keywords\"    content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">\n  <meta name=\"description\" content=\"Alumni email and web page directory for Mountain View High School (MVHS) and Awalt High School in Mountain View, CA. Updated $aid_util'caldate.\">\n  <meta name=\"author\"  content=\"$aid_util'config{'admin_name'}\">\n  <link rev=\"made\"     href=\"mailto:" . $aid_util'config{'admin_email'} . "\">\n  <link rel=\"start\"    href=\"http://" . $aid_util'config{'master_srv'} . $aid_util'config{'master_path'} . "\">\n  <link rel=\"contents\" href=\"http://" . $aid_util'config{'master_srv'} . $aid_util'config{'master_path'} . "\">";

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
    'bounces',			# number of bounces since last verif.
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
    'last',	'Last/Maiden Name',
    'married',	'Married Name',
    'first',	'First Name',
    'request',	'',
    'reunion',	'',
    'bounces',	'',
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
$aid_util'blank_entry{'request'} = 3;       #'#
$aid_util'blank_entry{'reunion'} = 1;       #'#
$aid_util'blank_entry{'bounces'} = 0;       #'#
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
	$year = $rec{'year'} % 100;
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
    $name =~ s/-//g;
    $name =~ s/\".*\"//g;
    $name =~ s/\(.*\)//g;
    $name =~ s/\'.*\'//g;

    $name;
}


sub aid_split {
    package aid_util;

    local($_) = @_;
    local($[) = 0;
    local(@fields) = split(/$FIELD_SEP/);
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

    $alias = substr($mangledFirst, 0, 1) . substr($mangledLast, 0, 7);
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

    @alpha = @db[sort bydatakeys $[..$#db];
    @alpha;
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
    $inFile = &main'aid_newsfile($id);

    if (-r $inFile) {
	open(TEXTFILE,$inFile) || die "Can't open $inFile: $!\n";
	while(<TEXTFILE>) { $text .= $_; }
	close(TEXTFILE);
    }
    
    $text;
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

    for ($i = 0; $i < 4; $i++) {
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
	    $body .= "<p><strong><font color=\"#$star_fg\">Your email ";
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
<tr><td align=right><input type=\"submit\" value=\"Next &gt;\">
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
  <td valign=top><font color=\"#$cell_fg\"><label for=\"last\">Last/Maiden
  Name</label></font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(your last name in high school)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"last\" size=35
  value=\"$rec{'last'}\" id=\"last\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#$cell_fg\"><label
  for=\"married\">Married Name</label></font><br>
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
  <br><strong><label for=\"message\">What's New?</label></strong>
  Write a paragraph about what you've been up to recently.</font><br>
  <textarea name=\"message\" rows=10 cols=55 wrap=hard
  id=\"message\">$rec{'message'}</textarea>
  </td>
</tr>
<tr>
  <td colspan=3><font color=\"#$cell_fg\"><input type=checkbox
  name=\"reunion\" id=\"reunion\" $reunion_chk><label
  for=\"reunion\">&nbsp;My class officers may notify me of
  reunion information via email.</label><br><br>Please 
  <a href=\"" . $config{'master_path'} . "etc/faq.html#mailings\">send 
  an updated copy</a> of the Directory to my email address every 3 
  months:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request3\"
  value=\"3\"$reqchk[3]><label
  for=\"request3\">&nbsp;Only new and changed alumni entries. [~ 10 kbytes]</label><br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request2\"
  value=\"2\"$reqchk[2]><label
  for=\"request2\">&nbsp;All alumni, sorted by graduating class. [~ 50 kbytes]</label><br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request1\"
  value=\"1\"$reqchk[1]><label
  for=\"request1\">&nbsp;All alumni, sorted by name. [~ 50 kbytes]</label><br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request0\"
  value=\"0\"$reqchk[0]><label
  for=\"request0\">&nbsp;No e-mail except for yearly address
  verification.</label></font>
  <input type=\"hidden\" name=\"id\" value=\"$rec{'id'}\">
  <input type=\"hidden\" name=\"created\" value=\"$rec{'created'}\">
  <input type=\"hidden\" name=\"valid\" value=\"1\">
  </td>
</tr>
</table>
</td></tr></table></td></tr>
<tr><td align=right><input type=\"submit\" value=\"Next &gt;\">
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
"From: $return_path ($from)\
Return-Path: $return_path\
Subject: $subject\
To: $toline\
";

    if (open(F, "| $config{'sendmail'} $to")) {
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

    $retval .= "<dt>Email: <code><strong><a href=\"mailto:$rec{'email'}\">";
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
    
    $retval .= "Married Name       : ";
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
    $retval .= "<strong>" .
	"<a href=\"" . &main'aid_about_path(*rec) . "\">" #'#
	    if $do_html_p && !$show_req_p;
    $retval .= $rec{'year'};
    $retval .= "</a></strong>" if $do_html_p && !$show_req_p;
    $retval .= "\n";

    $retval .= "\n";
    $retval .= "Email              : ";
    $retval .= "<strong><a href=\"mailto:$rec{'email'}\">" if $do_html_p;
    $retval .= $rec{'email'};
    $retval .= "</a></strong>" if $do_html_p;
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
	$retval .= "Send Email Updates : ";
	$retval .= ($rec{'request'} == 2) ?
	    "yes (sorted by graduating class)\n" :
	    ($rec{'request'} == 1) ? "yes (sorted by name)\n" : 
	    ($rec{'request'} == 3) ? "yes (new and changed entries)\n" : 
		"only address verification\n";
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
	$retval .= $rec{'message'};
	$retval .= $do_html_p ? "\n</blockquote>\n" : "";
    } else {
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
	"Copyright\n&copy; 1998 " . $config{'admin_name'} . "</a></font>\n\n" .
	"<!-- end common_html_ftr -->\n\n</body>\n</html>\n";

    $ftr;
}


sub common_html_hdr {
    require 'ctime.pl';
    require 'tableheader.pl';
    package aid_util;

    local($page,$title,$norobots) = @_;
    local($hdr,$result,$timestamp,$titletag);
    local($date) = &main'ctime(time);  #'#

    chop $date;
    $timestamp = (($page == 0) ? 'Last update to Directory: ' :
		  'Last update to this page: ') . $date;

    $result = &main'tableheader_internal($title,1,$header_fg); #'#

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
<table cellspacing=0 cellpadding=6 border=1 width=\"100%\">
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
    <strong>$result</strong>
";
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
	$retval .= ($year eq 'other') ? "Faculty/Staff" : $year % 100;
	$retval .= "</a>"
	    unless defined $hilite && $year eq $hilite && !$first;

	$first = 0;
    }

    $do_paragraph && $retval .= '</p>';
    $retval .= "\n\n";

    $retval;
}

1;

#
#     FILE: aid_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the Alumni Internet Directory
#      $Id: aid_util.pl,v 3.34 1998/08/18 16:24:17 mradwin Exp mradwin $
#

$aid_util'rcsid =
 '$Id: aid_util.pl,v 3.34 1998/08/18 16:24:17 mradwin Exp mradwin $';

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
     "Awalt&nbsp;Alumni,"     . $aid_util'config{'master_path'} . "awalt.html",  #'#
     "Recent&nbsp;Additions," . $aid_util'config{'master_path'} . "recent.html", #'#
     "Web&nbsp;Pages,"        . $aid_util'config{'master_path'} . "pages.html",  #'#
     );

@aid_util'second_idx = #'#
    (
     "Add&nbsp;Your&nbsp;Entry!,"  . $aid_util'config{'master_path'} . "add.html", #'#
     "Reunions,"            . $aid_util'config{'master_path'} . "reunions.html", #'#
     "Links,"               . $aid_util'config{'master_path'} . "links.html",    #'#
     "Nicknames,"           . $aid_util'config{'master_path'} . "books/",        #'#
     "Tech&nbsp;Notes,"     . $aid_util'config{'master_path'} . "tech.html",     #'#
     "Acceptable&nbsp;Use," . $aid_util'config{'master_path'} . "copyright.html", #'#
     );

($i,$i,$i,$aid_util'mday,$aid_util'mon,$aid_util'yr,$i,$i,$i) #')#
    = localtime(time);
$aid_util'caldate = sprintf("%d/%02d/%02d", ($aid_util'yr+1900),
    ($aid_util'mon+1), $aid_util'mday);

$aid_util'pics_label = #'#
"<meta http-equiv=\"PICS-Label\" content='(PICS-1.1 " . 
"\"http://www.rsac.org/ratingsv01.html\" l gen true " . 
"comment \"RSACi North America Server\" by \"" . 
$aid_util'config{'admin_email'} . 
"\" on \"1998.03.10T11:49-0800\" r (n 0 s 0 v 0 l 0))'>\n" .
"<meta http-equiv=\"PICS-Label\" content='(PICS-1.1 " . 
"\"http://www.classify.org/safesurf/\" l gen true " .
"for \"http://" . $aid_util'config{'master_srv'} . "\" by \"" . 
$aid_util'config{'admin_email'} .
"\" r (SS~~000 1 SS~~100 1))'>"; #"#

$aid_util'site_tags = #'#
"<meta name=\"keywords\"    content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">\n<meta name=\"description\" content=\"Alumni email and web page directory for Mountain View High School (MVHS) and Awalt High School in Mountain View, CA. Updated $aid_util'caldate.\">\n<meta name=\"author\"  content=\"$aid_util'config{'admin_name'}\">\n<link rev=\"made\"     href=\"mailto:" . $aid_util'config{'admin_email'} . "\">\n<link rel=\"start\"    href=\"http://" . $aid_util'config{'master_srv'} . $aid_util'config{'master_path'} . "\">\n<link rel=\"contents\" href=\"http://" . $aid_util'config{'master_srv'} . $aid_util'config{'master_path'} . "\">";

$aid_util'noindex = "<meta name=\"robots\"  content=\"noindex\">"; #'#
%aid_util'aid_aliases = ();   #'# global alias hash repository 

$aid_util'disclaimer = #'#
"<a name=\"disclaimer\">Acceptable use</a>: this directory
is provided solely for the information of alumni of Mountain View High
School and Awalt High School.  Any unauthorized solicitation of business,
information, contributions or other response from individuals listed in
this publication is forbidden.";

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
    'homepage',			# personal web page
    'location',			# city, company, or college
    'inethost',			# REMOTE_HOST of last update
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

#sub aid_tableheader {
#    require 'tableheader.pl';
#    package aid_util;
#
#    local($text) = @_;
#    
#    &main'tableheader($text,1,$header_bg,$header_fg,1); #'#
#}

# is the GMT less than one month ago?
# 2678400 = 31 days * 24 hrs * 60 mins * 60 secs
sub is_new {
    package aid_util;

    local($[) = 0;

    (((time - $_[0]) < 2678400) ? 1 : 0);
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

    $mangledLast = &main'mangle($rec{'last'});   #'#
    $mangledFirst = &main'mangle($rec{'first'}); #'#

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
	$rec{$_} =~ s/\s+/ /g;
    }

    %rec;
}

sub submit_body {
    package aid_util;

    local($[) = 0;
    local($_);
    local($body);
    local($star) = "<font color=\"#$star_fg\">*</font>";
    local(*rec_arg,$blankp) = @_;
    local(%rec) = &main'rec_html_entify(*rec_arg); #'#
    local($mvhs_checked,$awalt_checked,$other_checked) = ('', '', '');
    local(@reqchk,$i,$reunion_chk);

    $rec{'homepage'} = 'http://' if $rec{'homepage'} eq '';

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

    if ($rec{'id'} != -1) {
	$body = "
<p>Please update the following information and hit the
<strong>Next&nbsp;&gt;</strong> button.</p>

<p>Fields marked with a $star
are required.  All other fields are optional.</p>\n\n";

    } else {
	$body = "
<p>If you'd like to update your existing entry, please see the 
<a href=\"" . $config{'cgi_path'} . "/upl?update\">update page</a>.  
To update the entry for an alumnus with an invalid address, please see
the <a href=\"" . $config{'master_path'} . "invalid.html\">invalid
addresses page</a>.</p>

<p>To add a new alumnus, please enter the following information and hit
the <strong>Next&nbsp;&gt;</strong> button. Fields marked with a $star
are required.  All other fields are optional.</p>\n\n";
    }

    if ($blankp) {
	$body .= "<p><font color=\"#$star_fg\"><strong>You left one or more ";
	$body .= "required fields blank.\nPlease fill them in below ";
	$body .= "and resubmit.</strong></font></p>\n\n";
    }
	
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
  Name</label></font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"last\" size=35
  value=\"$rec{'last'}\" id=\"last\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#$cell_fg\"><label
  for=\"married\">Married Name</label></font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(if different from Maiden Name)</font></td>
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
  <font color=\"#$cell_fg\" size=\"-1\">(such as albert\@aol.com)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"email\" size=35
  value=\"$rec{'email'}\" id=\"email\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#$cell_fg\"><label
  for=\"homepage\">Personal Web Page</label></font></td>
  <td valign=top><input type=text name=\"homepage\" size=35
  value=\"$rec{'homepage'}\" id=\"homepage\"></td>
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
  <textarea name=\"message\" rows=10 cols=55 wrap=soft
  id=\"message\">$rec{'message'}</textarea>
  </td>
</tr>
<tr>
  <td colspan=3><font color=\"#$cell_fg\"><input type=checkbox
  name=\"reunion\" id=\"reunion\" $reunion_chk><label
  for=\"reunion\">&nbsp;My class officers may notify me of
  reunion information via email.</label><br><br>Please 
  <a href=\"" . $config{'master_path'} . "tech.html#mailings\">send 
  an updated copy</a> of the Directory to my email address every 3 
  months:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request3\"
  value=\"3\"$reqchk[3]><label
  for=\"request3\">&nbsp;Only new and changed alumni entries.</label><br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request2\"
  value=\"2\"$reqchk[2]><label
  for=\"request2\">&nbsp;All alumni, sorted by graduating class.</label><br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request1\"
  value=\"1\"$reqchk[1]><label
  for=\"request1\">&nbsp;All alumni, sorted by name.</label><br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" id=\"request0\"
  value=\"0\"$reqchk[0]><label
  for=\"request0\">&nbsp;No e-mail except for address
  verification (once per year).</label></font>
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

    "\n--\n" . 
	$config{'admin_name'} . "\n" .
	    $config{'admin_school'};


#	$config{'admin_school'} . "\n\n"
#	"Email     : " . $config{'admin_email'} . "\n" .
#	"WWW       : " . $config{'admin_url'} . "\n" .
#	"Phone     : " . $config{'admin_phone'};
}

sub aid_write_verbose_entry {
    require 'ctime.pl';
    package aid_util;

    local(*FMTOUT,*rec_arg,$display_year,$suppress_new) = @_;
    local($[) = 0;
    local($_);
    local($fullname);
    local(*rec);

    $rec_arg{'message'} = &main'aid_get_usertext($rec_arg{'id'});
    %rec = &main'rec_html_entify(*rec_arg);

    $fullname = &main'inorder_fullname(*rec); #'#

    print FMTOUT "<dl compact>\n";

    print FMTOUT "<dt><font size=\"+1\">";
    print FMTOUT "<strong>";
    print FMTOUT "<a name=\"id-$rec{'id'}\">";
    print FMTOUT  $fullname;
    print FMTOUT "</a>";
    print FMTOUT "</strong>";
    print FMTOUT "</font>\n";

    print FMTOUT "&nbsp;<font size=\"-1\">[";
    print FMTOUT "<a href=\"" . &main'aid_vcard_path($rec{'id'}) . "\">"; #'#
    print FMTOUT "vCard</a>";
    print FMTOUT "&nbsp;|&nbsp;";
    print FMTOUT "<a href=\"" . $config{'cgi_path'} . "/dyn?about=$rec{'id'}\">";
    print FMTOUT "update</a>";
    print FMTOUT "]</font>\n";
    
    print FMTOUT $image_tag{'new_anchored'}
	if !$suppress_new && &main'is_new($rec{'time'});  #'#

    print FMTOUT "</dt>\n";
    print FMTOUT "<dt>School: <strong>$rec{'school'}</strong></dt>\n" 
	if $rec{'school'} ne $config{'short_school'};

    if ($rec{'year'} =~ /^\d+$/) {
	if ($display_year) {
	    print FMTOUT "<dt>Year:  <strong>";
	    print FMTOUT 
		"<a href=\"" . &main'aid_about_path(*rec,1) . "\">"; #'#
	    print FMTOUT $rec{'year'};
	    print FMTOUT "</a></strong></dt>\n";
	}
    } else {
	print FMTOUT "<dt>Affiliation:  <strong>";
	print FMTOUT "<a href=\"" . &main'aid_about_path(*rec,1) . "\">"; #'#
	print FMTOUT $rec{'year'};
	print FMTOUT "</a></strong></dt>\n";
    }

    print FMTOUT "<dt>Email: <code><strong><a href=\"mailto:$rec{'email'}\">$rec{'email'}</a></strong></code></dt>\n";
    print FMTOUT "<dt>Web Page: <code><strong><a href=\"$rec{'homepage'}\">$rec{'homepage'}</a></strong></code></dt>\n"
	if $rec{'homepage'} ne '';
    print FMTOUT "<dt>Location: <strong>$rec{'location'}</strong></dt>\n"
	if $rec{'location'} ne '';
    print FMTOUT "<dt>Joined: ";
    $date = &main'ctime($rec{'created'}); chop $date;
    print FMTOUT "<strong>$date</strong></dt>\n";
    if ($rec{'time'} != $rec{'created'}) {
	print FMTOUT "<dt>Updated: ";
	$date = &main'ctime($rec{'time'}); chop $date;
	print FMTOUT "<strong>$date</strong></dt>\n";
    }

    if ($rec{'message'} ne '') {
	print FMTOUT "<dt>What's New?</dt>\n";
	print FMTOUT "<dd>$rec{'message'}</dd>\n";
    }
    print FMTOUT "</dl>\n\n";
}


sub about_text {
    require 'ctime.pl';
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
	    if $do_html_p;
    $retval .= $rec{'year'};
    $retval .= "</a></strong>" if $do_html_p;
    $retval .= "\n";

    $retval .= "\n";
    $retval .= "Email              : ";
    $retval .= "<strong><a href=\"mailto:$rec{'email'}\">" if $do_html_p;
    $retval .= $rec{'email'};
    $retval .= "</a></strong>" if $do_html_p;
    $retval .= "\n";

    $retval .= "Personal Web Page  : ";
    $retval .= ($rec{'homepage'} eq '') ? "(none)\n" :
	((($do_html_p) ? "<strong><a href=\"$rec{'homepage'}\">" : "") .
	 $rec{'homepage'} . 
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
	$retval .= &main'ctime($rec{'created'}); #'#
    }

    if ($rec{'time'} ne '' && $rec{'time'} != 0) {
	$retval .= "Last Updated       : ";
	$retval .= &main'ctime($rec{'time'}); #'#
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

    local($page) = @_;
    local($ftr,$copyright);

    $copyright = $second_idx[5];
    $copyright =~ s/^[^,]+,//;

    $ftr  = "\n<!-- begin common_html_ftr -->\n";
    $ftr .= "<table cellspacing=0 cellpadding=6 border=1 width=\"100%\">\n" .
	"  <tr>\n    <td bgcolor=\"#$cell_bg\" valign=middle>\n";
#   $ftr .= "<hr noshade size=1>\n";
    $ftr .= &main'common_link_table($page); #'#
    $ftr .= "\n" . $disclaimer . "\n\n";
    $ftr .= "    </td>\n  </tr>\n</table>\n";

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

    $hdr  = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">\n" .
	"<!--  " . $config{'rcsid'} . " -->\n" .
	"<html>\n<head>\n" .
	"<title>" . $titletag .
	"</title>\n" . $pics_label . "\n" . $site_tags . "\n";
    $hdr .= "$noindex\n" if $norobots;
    $hdr .= "</head>\n\n";
    
    $hdr .= "<!-- begin common_html_hdr -->\n";

    $hdr .= "<body bgcolor=\"#$body_bg\" text=\"#$body_fg\" link=\"#$body_link\" vlink=\"#$body_vlink\">\n\n";
    
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

1;

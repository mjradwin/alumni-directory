#
#     FILE: aid_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the Alumni Internet Directory
#      $Id: aid_util.pl,v 1.98 1998/02/23 21:03:49 mjr Exp mjr $
#

$aid_util'rcsid =
 '$Id: aid_util.pl,v 1.98 1998/02/23 21:03:49 mjr Exp mjr $';

# ----------------------------------------------------------------------
# CONFIGURATION
#
# to revise the AID for another school, you should edit the 
# *aid_util'variables in this configuration section, and the
# subroutines submit_body() and affiliate()
# ----------------------------------------------------------------------

# divcom.umop-ap.com configuration
%aid_util'config =  #'font-lock
    ('admin_name',   'Michael John Radwin',
     'admin_email',  "mjr\@acm.org",
     'school',       'Mountain View High School',
     'admin_school', "Mountain View High School, Class of '93",
     'admin_phone',  '408-536-2554',
     'admin_url',    'http://slimy.com/~mjr/',
     'master_srv',   'umop-ap.com',
     'master_path',  '/~mjr/mvhs/',
     'cgi_path',     '/cgi-bin/cgiwrap/mjr/mvhsaid',
     'index_page',   'index.html',
     'wwwdir',       '/home/divcom/mjr/public_html/mvhs/',
     'newsdir',      '/home/divcom/mjr/public_html/mvhs/whatsnew/',
     'aiddir',       '/home/divcom/mjr/mvhs/',
     'sendmail',     '/usr/lib/sendmail',
     'mailprog',     '/usr/ucb/mail',
     'echo',         '/usr/bin/echo',
     'cat',          '/usr/local/gnu/bin/cat',
     'cp',           '/usr/local/gnu/bin/cp',
     'make',         '/usr/local/gnu/bin/make',
     'mailto',       "mjr\@divcom",
     'mailsubj',     'MVHSAID',
     'spoolfile',    '/var/spool/mail/mjr',
     'rcsid',        "$aid_util'rcsid",
     );

# albert.corp.adobe.com configuration
# %aid_util'config =  #'font-lock
#     ('admin_name',   'Michael John Radwin',
#      'admin_email',  "mjr\@acm.org",
#      'school',       'Mountain View High School',
#      'admin_school', "Mountain View High School, Class of '93",
#      'admin_phone',  '408-536-2554',
#      'admin_url',    'http://slimy.com/~mjr/',
#      'master_srv',   'albert.corp.adobe.com',
#      'master_path',  '/~mradwin/mvhs/',
#      'cgi_path',     '/~mradwin/mvhs/cgi-bin/mvhsaid.cgi',
#      'index_page',   'index.html',
#      'wwwdir',       '/user/mradwin/public_html/mvhs/',
#      'newsdir',      '/user/mradwin/public_html/mvhs/whatsnew/',
#      'aiddir',       '/user/mradwin/mvhs/',
#      'sendmail',     '/usr/lib/sendmail',
#      'mailprog',     '/usr/ucb/mail',
#      'mailto',       "mradwin",
#      'mailsubj',     'MVHSAID',
#      'spoolfile',    '/var/mail/mradwin', 
#      'rcsid',        "$aid_util'rcsid",
#      );

# foo.metamorphosis.net configuration
#%aid_util'config =   #'font-lock
#     ('admin_name',   'Michael John Radwin',
#      'admin_email',  "mjr\@acm.org",
#      'school',       'BrownCS',
#      'admin_school', "BrownCS, Class of '97",
#      'admin_phone',  '408-536-2554',
#      'admin_url',    'http://slimy.com/~mjr/',
#      'master_srv',   'metamorphosis.net',
#      'master_path',  '/~mjr/browncs/',
#      'cgi_path',     '/~mjr/cgi-bin/browncsaid.cgi',
#      'index_page',   'index.html',
#      'wwwdir',       '/home/mjr/public_html/browncs/',
#      'newsdir',      '/home/mjr/public_html/browncs/whatsnew/',
#      'aiddir',       '/home/mjr/browncs/',
#      'sendmail',     '/usr/sbin/sendmail',
#      'mailprog',     '/usr/bin/mail',
#      'mailto',       "mjr\@foo",
#      'mailsubj',     'MVHSAID',
#      'spoolfile',    '/var/mail/mjr',
#      'rcsid',        "$aid_util'rcsid",
#      );

@aid_util'page_idx = #'font-lock
    ("Home,"                  . $aid_util'config{'master_path'},                 #'
     "Alphabetically,"        . $aid_util'config{'master_path'} . "all.html",    #'
     "Grad.&nbsp;Class,"      . $aid_util'config{'master_path'} . "class/",      #'
     "Awalt&nbsp;Alumni,"     . $aid_util'config{'master_path'} . "awalt.html",  #'
     "Recent&nbsp;Additions," . $aid_util'config{'master_path'} . "recent.html", #'
     "Web&nbsp;Pages,"        . $aid_util'config{'master_path'} . "pages.html",  #'
     "Get&nbsp;Listed!,"      . $aid_util'config{'master_path'} . "add.html",    #'
     );

@aid_util'second_idx = #'font-lock
    ("Listings,"            . $aid_util'config{'master_path'} . "listings.html", #'
     "Reunions,"            . $aid_util'config{'master_path'} . "reunions.html", #'
     "Links,"               . $aid_util'config{'master_path'} . "links.html",    #'
     "Nicknames,"           . $aid_util'config{'master_path'} . "books/",        #'
     "Tech&nbsp;Notes,"     . $aid_util'config{'master_path'} . "tech.html",     #'
     "Acceptable&nbsp;Use," . "#disclaimer",
     );

($i,$i,$i,$aid_util'mday,$aid_util'mon,$aid_util'yr,$i,$i,$i)
 = localtime(time);
$aid_util'caldate = sprintf("%d/%02d/%02d", ($aid_util'yr+1900),
 ($aid_util'mon+1), $aid_util'mday);

$aid_util'pics_label = #'font-lock
"<meta http-equiv=\"PICS-Label\" content='(PICS-1.1 \"http://www.rsac.org/ratingsv01.html\" l gen true comment \"RSACi North America Server\" by \"" . 
$aid_util'config{'admin_email'} . "\" for \"http://" .
$aid_util'config{'master_srv'} . $aid_util'config{'master_path'} . #'font-lock
"\" on \"1996.04.04T08:15-0500\" r (n 0 s 0 v 0 l 0))'>";

$aid_util'site_tags = #'font-lock
"<meta name=\"keywords\" content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">\n<meta name=\"description\" content=\"Alumni email and web page directory for Mountain View High School (MVHS) and Awalt High School in Mountain View, CA. Updated $aid_util'caldate.\">";

$aid_util'noindex = "<meta name=\"robots\" content=\"noindex\">"; #'font-lock
%aid_util'aid_aliases = ();   #' global alias hash repository 

$aid_util'disclaimer = #'font-lock
"<blockquote><a name=\"disclaimer\">Acceptable use</a>: this directory
is provided solely for the information of alumni of Mountain View High
School and Awalt High School.  Any solicitation of business,
information, contributions or other response from individuals listed in
this publication is forbidden.</blockquote>";

$aid_util'header_bg  = 'ffff99'; #'font-lock
$aid_util'header_fg  = '000000'; #'font-lock

$aid_util'cell_bg    = 'ffffcc'; #'font-lock
$aid_util'cell_fg    = '000000'; #'font-lock

$aid_util'star_fg    = 'ff0000'; #'font-lock

$aid_util'body_bg    = 'ffffff'; #'font-lock
$aid_util'body_fg    = '000000'; #'font-lock
$aid_util'body_link  = '0000cc'; #'font-lock
$aid_util'body_vlink = '990099'; #'font-lock

$aid_util'FIELD_SEP   = ";";   #' character that separates fields in DB
$aid_util'ID_INDEX    = 1;     #' position that the ID key is in datafile
@aid_util'field_names = #' order is important!
    (
     'time',
     'id',
     'request',
     'last',
     'first',
     'married',
     'school',
     'year',
     'email',
     'homepage',
     'location',
     'created',
     'inethost',
     );

%aid_util'blank_entry =        #' a prototypical blank entry to clone
    ();

for ($i = 0; $i <= $#aid_util'field_names; $i++) { #'
     $aid_util'blank_entry{$aid_util'field_names[$i]} = '';
}

$aid_util'blank_entry{'id'}      = -1;
$aid_util'blank_entry{'request'} = 2;
$aid_util'blank_entry{'message'} = '';
$aid_util'blank_entry{'school'}  = 'MVHS';  #'font-lock

%aid_util'image_tag = #'font-lock
    (
     'new',
     "<img src=\"" . $aid_util'config{'master_path'} . #'fnt
     "new.gif\" border=0 width=28 height=11 " .
     "alt=\"[new]\">",
     
     'new_anchored',
     "<a href=\"" . $aid_util'config{'master_path'} . "recent.html\">" .
     "<img src=\"" . $aid_util'config{'master_path'} .
     "new.gif\" border=0 width=28 height=11 " .
     "alt=\"[new]\"></a>",

     'title',
     "<img src=\"" . $aid_util'config{'master_path'} . #'fnt
     "title.gif\"\nborder=0 align=bottom width=398 height=48\n" .
     "alt=\"Mountain View High School Alumni Internet Directory\">",

     'vcard',
     "<img src=\"" . $aid_util'config{'master_path'} . #'fnt
     "vcard.gif\" border=0 align=top width=32 height=32 " .
     "alt=\"[vCard]\">",

     'info',
     "<img src=\"" . $aid_util'config{'master_path'} . #'fnt
     "info.gif\" border=0 hspace=4 width=12 height=12 " .
     "alt=\"[i]\">",

     'blank',
     "<img src=\"" . $aid_util'config{'master_path'} . #'fnt
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

sub aid_tableheader {
    require 'tableheader.pl';
    package aid_util;

    local($text) = @_;
    
    &main'tableheader($text,1,$header_bg,$header_fg,1); #'fnt
}

# is the GMT less than one month ago?
# 2678400 = 31 days * 24 hrs * 60 mins * 60 secs
sub is_new {
    package aid_util;

    local($[) = 0;

    (((time - $_[0]) < 2678400) ? 1 : 0);
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
	$affil .= "<a href=\"" . $config{'master_path'} . 
	    "class/$rec{'year'}.html\">" if $do_html_p;

	$year = $rec{'year'} % 100;
	if ($rec{'school'} eq 'Awalt') {
	    $affil  .= "A'$year";
	    $len    += length("A'$year");
	} elsif ($rec{'school'} eq 'MVHS' || $rec{'school'} eq '') {
	    $affil  .= "'$year";
	    $len    += length("'$year");
	} else {
	    $affil  .= "$rec{'school'} '$year";
	    $len    += length("$rec{'school'} '$year");
	}

	$affil .= "</a>" if $do_html_p;

    } else {
	$affil .= "<a href=\"" . $config{'master_path'} . 
	    "class/other.html\">" if $do_html_p;
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
    local(%rec) = &main'aid_split($_); #'font-lock
    local($mangledLast,$mangledFirst,$alias);

    $mangledLast = &main'mangle($rec{'last'});   #' font-lock
    $mangledFirst = &main'mangle($rec{'first'}); #' font-lock

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

sub aid_util'bydatakeys {   #'fnt
    package aid_util;
    $datakeys[$a] cmp $datakeys[$b];
}
 
sub aid_alpha_db {
    package aid_util;

    local($filename) = @_;
    local(@db) = &main'aid_create_db($filename);   #'fnt
    local(%rec);
    local($[) = 0;
    local($_);

    @datakeys = ();

    foreach (@db) {
	%rec = &main'aid_split($_);  #'font-lock
	push(@datakeys, "$rec{'last'},$rec{'married'},$rec{'first'}");
    }

    @alpha = @db[sort bydatakeys $[..$#db];
    @alpha;
}

sub aid_get_usertext {
    package aid_util;

    local($id) = @_;
    local($_);
    local($text,$inFile,*TEXTFILE);

    $text = '';
    $inFile = $config{'newsdir'} . "${id}.txt";

    if (-r $inFile) {
	open(TEXTFILE,$inFile) || die "Can't open $inFile: $!\n";
	while(<TEXTFILE>) { $text .= $_; }
	close(TEXTFILE);
    }
    
    $text;
}


sub rec_html_entify {
    package aid_util;

    local(*rec) = @_;
    local(%newrec,$_);

    %newrec = %rec;

    foreach (keys %newrec) {
	$newrec{$_} =~ s/&/&amp;/g;
	$newrec{$_} =~ s/</&lt;/g;
	$newrec{$_} =~ s/>/&gt;/g;
	$newrec{$_} =~ s/"/&quot;/g; #" fnt
	$newrec{$_} =~ s/\s+/ /g;
    }

    %newrec;
}

sub submit_body {
    package aid_util;

    local($[) = 0;
    local($_);
    local($tableh);
    local($star) = "<font color=\"#$star_fg\">*</font>";
    local(*rec,$blankp) = @_;
    local(%newrec) = &main'rec_html_entify(*rec);
    local($mvhs_checked,$awalt_checked,$other_checked) = ('', '', '');
    local(@reqchk,$i);

    $newrec{'homepage'} = 'http://' if $newrec{'homepage'} eq '';

    for ($i = 0; $i < 3; $i++) {
	$reqchk[$i] = ($newrec{'request'} == $i) ? ' checked' : '';
    }

    if ($newrec{'school'} eq 'MVHS' || $newrec{'school'} eq '') {
	$mvhs_checked = ' checked';
	$newrec{'school'} = '';
    } elsif ($newrec{'school'} eq 'Awalt') {
	$awalt_checked = ' checked';
	$newrec{'school'} = '';
    } else {
	$other_checked = ' checked';
	$newrec{'school'} = '' if $newrec{'school'} eq 'Other';
    }

    if ($newrec{'id'} != -1) {
	$tableh = &main'aid_tableheader('Update Your Directory Listing'); #'f
	$tableh .= "
<p>Please update the following information and hit the
<strong>Next&nbsp;&gt;</strong> button.</p>

<p>Fields marked with a $star
are required.  All other fields are optional.</p>\n\n";

    } else {
	$tableh = &main'aid_tableheader('Add a Listing to the Directory'); #'f
	$tableh .= "
<p>If you'd like to update your existing entry, please see the 
<a href=\"" . $config{'cgi_path'} . "?update\">update page</a>.  
To update the entry for an alumnus with an invalid address, please see
the <a href=\"" . $config{'master_path'} . "invalid.html\">invalid
addresses page</a>.</p>

<p>To add a new alumnus, please enter the following information and hit
the <strong>Next&nbsp;&gt;</strong> button. Fields marked with a $star
are required.  All other fields are optional.</p>\n\n";
    }

    if ($blankp) {
	$tableh .= "<p><font color=\"#$star_fg\"><strong>You left one or more ";
	$tableh .= "required fields blank.\nPlease fill them in below ";
	$tableh .= "and resubmit.</strong></font></p>\n\n";
    }
	
    "<br>\n" . $tableh . "
<form method=post action=\"" . $config{'cgi_path'} . "\"> 
<table border=0>
<tr><td>
<table border=0 width=\"100%\">
<tr><td bgcolor=\"#$cell_bg\"><table border=0 cellspacing=7>
<tr>
  <td valign=top><font color=\"#$cell_fg\">First Name</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"first\" size=35 
  value=\"$newrec{'first'}\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#$cell_fg\">Last/Maiden Name</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"last\" size=35
  value=\"$newrec{'last'}\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#$cell_fg\">Married Name</font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(if different from Maiden Name)</font></td>
  <td valign=top><input type=text name=\"married\" size=35
  value=\"$newrec{'married'}\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#$cell_fg\">High School</font></td>
  <td>$star</td>
  <td valign=top><input type=radio name=\"school\"
  value=\"MVHS\"$mvhs_checked><font color=\"#$cell_fg\">&nbsp;MVHS&nbsp;&nbsp;&nbsp;&nbsp;<input
  type=radio name=\"school\" value=\"Awalt\"$awalt_checked>&nbsp;Awalt</font></td>
</tr>
<tr>
  <td valign=top>&nbsp;</td>
  <td valign=top>&nbsp;</td>
  <td valign=top><input type=radio name=\"school\" 
  value=\"Other\"$other_checked><font color=\"#$cell_fg\">&nbsp;Other:&nbsp;</font><input type=text
  name=\"sch_other\" size=27 value=\"$newrec{'school'}\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#$cell_fg\">Graduation year or affiliation</font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(such as 1993, 2001, or Teacher)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"year\" size=35
  value=\"$newrec{'year'}\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#$cell_fg\">E-mail address</font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(such as albert\@aol.com)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"email\" size=35
  value=\"$newrec{'email'}\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#$cell_fg\">Web Page</font></td>
  <td valign=top><input type=text name=\"homepage\" size=35
  value=\"$newrec{'homepage'}\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#$cell_fg\">Location</font><br>
  <font color=\"#$cell_fg\" size=\"-1\">(your city, school, or company)</font></td>

  <td valign=top><input type=text name=\"location\" size=35
  value=\"$newrec{'location'}\"></td>
</tr>
<tr>
  <td colspan=3><font color=\"#$cell_fg\">
  <br><strong>What's New?</strong> Tell us, in 100 words or less, what
  you've been up to recently.</font>
  $image_tag{'new'}<br>
  <textarea name=\"message\" rows=10 cols=55 wrap>$newrec{'message'}</textarea>
  </td>
</tr>
<tr>
  <td colspan=3><font color=\"#$cell_fg\"><br>Please 
  <a href=\"" . $config{'master_path'} . "tech.html#mailings\">send 
  an updated copy</a> of the Directory to my email address every 3-4 
  months:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\"
  value=\"1\"$reqchk[1]>&nbsp;&nbsp;Sorted by name.<br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" 
  value=\"2\"$reqchk[2]>&nbsp;&nbsp;Sorted by graduating class.<br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\"
  value=\"0\"$reqchk[0]>&nbsp;&nbsp;No, please do not send me copies
  of the Directory.</font>
  </td>
</tr>
</table>
</td></tr></table></td></tr>
<tr><td align=right><input type=\"submit\" value=\"Next &gt;\">
&nbsp;
<input type=\"reset\" value=\"Start Over\">
<input type=\"hidden\" name=\"id\" value=\"$newrec{'id'}\">
<input type=\"hidden\" name=\"created\" value=\"$newrec{'created'}\">
</td></tr></table>
</form>

";

}


sub sendmail {
    package aid_util;

    local($to,$return_path,$from,$subject,$body) = @_;
    local(*F);
    local($toline) = join(', ', split(/[ \t]+/, $to));
    local($header) =
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
	$config{'admin_school'} . "\n\n" .
	"Email     : " . $config{'admin_email'} . "\n" .
	"WWW       : " . $config{'admin_url'} . "\n" .
	"Phone     : " . $config{'admin_phone'};
}

sub about_text {
    require 'ctime.pl';
    package aid_util;

    local($retval) = '';
    local(*rec,$show_req_p,$do_html_p,$do_vcard_p) = @_;
    local(%newrec) = $do_html_p ? &main'rec_html_entify(*rec) : %rec; #'

    $do_vcard_p = 0 unless defined($do_vcard_p);

    $retval .= "<table border=0 cellpadding=6><tr><td bgcolor=\"#$cell_bg\"><font color=\"#$cell_fg\"><pre>\n\n" if $do_html_p;

    $retval .= "First Name         : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $newrec{'first'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Last/Maiden Name   : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $newrec{'last'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Married Name       : ";
    if ($newrec{'married'} eq '') {
	$retval .= "(same as last name)";
    } else {
	$retval .= "<strong>" if $do_html_p;
	$retval .= $newrec{'married'};
	$retval .= "</strong>" if $do_html_p;
    }
    $retval .= "\n";
    
    $retval .= "\n";
    $retval .= "School             : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $newrec{'school'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Grad. Year         : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $newrec{'year'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";

    $retval .= "\n";
    $retval .= "Email              : ";
    $retval .= "<strong><a href=\"mailto:$newrec{'email'}\">" if $do_html_p;
    $retval .= $newrec{'email'};
    $retval .= "</a></strong>" if $do_html_p;
    $retval .= "\n";

    $retval .= "Web Page           : ";
    $retval .= ($newrec{'homepage'} eq '') ? "(none)\n" :
	((($do_html_p) ? "<strong><a href=\"$newrec{'homepage'}\">" : "") .
	 $newrec{'homepage'} . 
	 (($do_html_p) ? "</a></strong>" : "") .
	 "\n");

    $retval .= "Location           : ";
    $retval .= ($newrec{'location'} eq '') ? "(none)\n" :
	((($do_html_p) ? "<strong>" : "") .
	 $newrec{'location'} .
	 (($do_html_p) ? "</strong>" : "") .
	 "\n");

    if ($do_vcard_p && $do_html_p) {
	$retval .= "vCard              : ";
	$retval .= "<a href=\"$config{'cgi_path'}/vcard/$newrec{'id'}.vcf\">";
	$retval .= $image_tag{'vcard'};
	$retval .= "</a>\n";
    }

    if ($show_req_p) {
	$retval .= "\n";
	$retval .= "Send Email Updates : ";
	$retval .= ($newrec{'request'} == 2) ?
	    "yes (sorted by graduating class)\n" :
	    ($newrec{'request'} == 1) ? "yes (sorted by name)\n" : "no\n";
    } 

    if ($newrec{'time'} ne '' && $newrec{'time'} != 0 &&
	$newrec{'created'} ne '' && $newrec{'created'} != 0) {
	$retval .= "\n";
	$retval .= "Joined Directory   : ";
	$retval .= &main'ctime($newrec{'created'}); #'fnt
    }

    if ($newrec{'time'} ne '' && $newrec{'time'} != 0) {
	$retval .= "Last Updated       : ";
	$retval .= &main'ctime($newrec{'time'}); #'fnt
    }

    $newrec{'message'} = &main'aid_get_usertext($newrec{'id'}) #'fnt
	unless defined($newrec{'message'});

    if ($newrec{'message'} ne '') {
	$retval .= "\n";
	$retval .= "What's New?        :\n";
	$retval .= "</pre>\n" if $do_html_p;
	$retval .= $do_html_p ? "<blockquote>\n" : "";
	$retval .= $newrec{'message'};
	$retval .= $do_html_p ? "\n</blockquote>\n" : "";
    } else {
	$retval .= "</pre>\n" if $do_html_p;
    }

    $retval .= "</font></td></tr></table>\n" if $do_html_p;

    if ($do_html_p && $newrec{'time'} ne '' && $newrec{'time'} != 0) {
	$retval .= &main'modify_button($newrec{'id'},
				       &main'inorder_fullname(*newrec));
    }

    $retval;
}

sub modify_button {
    package aid_util;

    local($id,$name) = @_;
    local($cgi) = $config{'cgi_path'};

    "
<!-- borrowed from gamelan -->
To update the entry for this person, please click the button below.

<form method=get action=\"$cgi\">
<center><input type=hidden name=\"update\" value=\"$id\">
<input type=submit value=\"Update $name\">
</center>
</form>

To avoid malicious modification by other people passing through, we
mail the original user about the change (plus the new user if the
email changes). The honor system has worked for us so far; please
don't abuse it and force us to install a password door.<p>
";
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

sub common_html_ftr {
    package aid_util;

    local($page) = @_;
    local($rcstag) = "<!-- " . $config{'rcsid'} . " -->";
    local($ftr,$name,$url,$idx);

    $ftr  = "\n<!-- begin common_html_ftr -->\n$rcstag\n\n";
    $ftr .= "<hr noshade size=1>\n<p align=center><font size=\"-1\">";

    foreach $idx (0 .. $#page_idx) {
	($name, $url) = split(/,/, $page_idx[$idx]);
        if ($idx == $page) {
	    $ftr .= "\n  <strong>$name</strong>";
        } else {
            $ftr .= "<a\n  href=\"$url\">$name</a>";
        }
	$ftr .= " || " unless $idx == $#page_idx;
    }
    $ftr .= "\n  <br>";
    foreach $idx (0 .. $#second_idx) {
	($name, $url) = split(/,/, $second_idx[$idx]);
        if ($idx == ($page - 10)) {
	    $ftr .= "\n  <strong>$name</strong>";
        } else {
            $ftr .= "<a\n  href=\"$url\">$name</a>";
        }
	$ftr .= " || " unless $idx == $#second_idx;
    }
    $ftr .= "\n</font></p>\n";
    
    $ftr .= "\n$disclaimer\n\n<hr noshade size=1>\n<p><a href=\"" .
	$config{'admin_url'} . "\"><em>" . $config{'admin_name'} .
	"</em></a><em>,</em> <a\nhref=\"mailto:" . $config{'admin_email'} . 
	"\"><tt>" . $config{'admin_email'} . "</tt></a></p>\n\n" .
	"<!-- end common_html_ftr -->\n\n</body>\n</html>\n";

    $ftr;
}


sub common_html_hdr {
    require 'ctime.pl';
    package aid_util;

    local($page,$norobots) = @_;
    local($h1,$h2,$h3,$html_head);
    local($name,$url,$idx);
    local($timestamp);
    local($rcstag) = "<!-- " . $config{'rcsid'} . " -->";
    local($date) = &main'ctime(time);  #'font-lock

    chop($date);
    $timestamp = (($page == 0) ? 'Last update to Directory: ' :
		  'Last update to this page: ') . $date;

    $h1 = "<body bgcolor=\"#$body_bg\" text=\"#$body_fg\" link=\"#$body_link\" vlink=\"#$body_vlink\">
<hr noshade size=1>
<table border=0 cellpadding=5 cellspacing=0 width=\"100%\">
<tr>
  <td bgcolor=\"#$cell_bg\" valign=top align=left rowspan=2><font size=\"-1\">";

    $h2 = "";
    foreach $idx (0 .. $#page_idx) {
	($name, $url) = split(/,/, $page_idx[$idx]);
        if ($idx == $page) {
	    $h2 .= "\n  <font color=\"#$cell_fg\"><strong>$name</strong></font>";
        } else {
            $h2 .= "<a\n  href=\"$url\">$name</a>";
        }
	$h2 .= "<br>" unless $idx == $#page_idx;
    }
    $h2 .= "</font></td>\n";

    $h2 .= "  <td bgcolor=\"#$cell_bg\" valign=top align=left rowspan=2><font size=\"-1\"><br>";
    foreach $idx (0 .. $#second_idx) {
	($name, $url) = split(/,/, $second_idx[$idx]);
        if ($idx == ($page - 10)) {
	    $h2 .= "\n  <font color=\"#$cell_fg\"><strong>$name</strong></font>";
        } else {
            $h2 .= "<a\n  href=\"$url\">$name</a>";
        }
	$h2 .= "<br>" unless $idx == $#second_idx;
    }
    $h2 .= "</font></td>\n";

    $h3 = "  <td align=right valign=top bgcolor=\"#$cell_bg\">&nbsp;<a href=\"" .
	$config{'master_path'} . "\">" . $image_tag{'title'} .
"</a></td>
</tr>
<tr>
  <td align=right valign=bottom bgcolor=\"#$cell_bg\"><font size=\"-1\"
  color=\"#$cell_fg\"><i>$timestamp</i></font>
  </td>
</tr>
</table>
<hr noshade size=1>

<!-- discourage www.roverbot.com -->
<!--BAD-DOG-->

";

    $html_head = "<html>\n<head>\n" .
	"<title>" . $config{'school'} . " Alumni Internet Directory" .
	"</title>\n" . $site_tags . "\n" . $pics_label . "\n";
    $html_head .= "$noindex\n" if $norobots;
    $html_head .= "</head>\n\n";
    
    $html_head .
	"<!-- begin common_html_hdr -->\n$rcstag\n" .
        $h1 . $h2 . $h3 .
        "<!-- end common_html_hdr -->\n";
}

1;

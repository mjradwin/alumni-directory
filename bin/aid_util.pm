#
#     FILE: aid_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the MVHS Alumni Internet Directory
#      $Id: aid_util.pl,v 1.78 1997/12/31 21:31:39 mjr Exp mjr $
#

# divcom.umop-ap.com configuration
%aid_util'config =  #'font-lock
    ('admin_name',   'Michael John Radwin',
     'admin_email',  "mjr\@acm.org",
     'admin_school', "Mountain View High School, Class of '93",
     'admin_phone',  '408-536-2554',
     'admin_url',    'http://slimy.com/~mjr/',
     'master_srv',   'umop-ap.com',
     'master_path',  '/~mjr/mvhs/',
     'cgi_path',     '/cgi-bin/cgiwrap/mjr/mvhsaid',
     'index_page',   'index.html',
     'wwwdir',       '/home/divcom/mjr/public_html/mvhs/',
     'newsdir',      '/home/divcom/mjr/public_html/mvhs/whatsnew/',
     'mvhsdir',      '/home/divcom/mjr/mvhs/',
     'sendmail',     '/usr/lib/sendmail',
     'mailprog',     '/usr/ucb/mail',
     'mailto',       "mjr\@divcom",
     'mailsubj',     'MVHSAID',
     'spoolfile',    '/var/spool/mail/mjr',
     'rcsid',        '$Id: aid_util.pl,v 1.78 1997/12/31 21:31:39 mjr Exp mjr $',
     );

# foo.metamorphosis.net configuration
#%aid_util'config =   #'font-lock
#    ('admin_name',   "Michael John Radwin",
#     'admin_email',  "mjr\@acm.org",
#     'admin_school', "Mountain View High School, Class of '93",
#     'admin_phone',  "408-536-2554",
#     'admin_url',    "http://umop-ap.com/~mjr/",
#     'master_srv',   "metamorphosis.net",
#     'master_path',  "/~mjr/mvhs/",
#     'cgi_path',     "/~mjr/cgi-bin/mvhsaid.cgi",
#     'index_page',   "index.html",
#     'wwwdir',       "/home/mjr/public_html/mvhs/",
#     'mvhsdir',      "/home/mjr/mvhs/",
#     'sendmail',     "/usr/sbin/sendmail",
#     'mailprog',     "/usr/bin/mail",
#     'mailto',       "mjr\@foo",
#     'mailsubj',     "MVHSAID",
#     );

@aid_util'page_idx = #'font-lock
    ("Home,"                  . $aid_util'config{'master_path'},
     "Alphabetically,"        . $aid_util'config{'master_path'} . "all.html",
     "Grad.&nbsp;Class,"      . $aid_util'config{'master_path'} . "class/",
     "Awalt&nbsp;Alumni,"     . $aid_util'config{'master_path'} . "awalt.html",
     "Recent&nbsp;Additions," . $aid_util'config{'master_path'} . "recent.html",
     "Web&nbsp;Pages,"        . $aid_util'config{'master_path'} . "pages.html",
     "Get&nbsp;Listed!,"      . $aid_util'config{'master_path'} . "add.html",
     );

@aid_util'second_idx =  #'font-lock
    ("Listings,"            . $aid_util'config{'master_path'} . "listings.html",
     "Reunions,"            . $aid_util'config{'master_path'} . "reunions.html",
     "Links,"               . $aid_util'config{'master_path'} . "links.html",
     "Nicknames,"           . $aid_util'config{'master_path'} . "books/",
     "Tech&nbsp;Notes,"     . $aid_util'config{'master_path'} . "tech.html",
     "Acceptable&nbsp;Use," . "#disclaimer",
     );

$aid_util'pics_label =
"<meta http-equiv=\"PICS-Label\" content='(PICS-1.1 \"http://www.rsac.org/ratingsv01.html\" l gen true comment \"RSACi North America Server\" by \"" . 
$aid_util'config{'admin_email'} . "\" for \"http://" .
$aid_util'config{'master_srv'} . $aid_util'config{'master_path'} . 
"\" on \"1996.04.04T08:15-0500\" r (n 0 s 0 v 0 l 0))'>"; #"font-lock;

$aid_util'site_tags = #'font-lock
"<meta name=\"keywords\" content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">\n<meta name=\"description\" content=\"email/web page listing of alumni, students, faculty and staff from Mountain View High School in Mountain View, California.  Also catalogues alumni from Chester F. Awalt High School, which was merged with MVHS in the early 80's.\">";

$aid_util'noindex = "<meta name=\"robots\" content=\"noindex\">"; #'font-lock
%aid_util'aid_aliases = ();   #' global alias hash repository 

# give 'em back the configuration variable they need
sub aid_config {
    package aid_util;

    die "NO CONFIG $_[0]!\n" if !defined($config{$_[0]});
    return $config{$_[0]};
}

# is the GMT less than one month ago?
# 2678400 = 31 days * 24 hrs * 60 mins * 60 secs
sub is_new {
    package aid_util;

    return ((time - $_[0]) < 2678400) ? 1 : 0;
}


# &new_gif(1) for anchored, &new_gif(0) for just plain img
sub new_gif {
    package aid_util;

    local($tag) = "<img src=\"" . $config{'master_path'} . 
	"new.gif\" border=0 width=28 height=11 alt=\"[new]\">";

    return (($_[0] ?
	     "<a href=\"" . $config{'master_path'} . "recent.html\">" :
	     "") . $tag . ($_[0] ? "</a>" : ""));
}


sub fullname {
    package aid_util;

    local($first,$last,$married) = @_;

    if ($first eq '') {
	return $last;
    } else {
	if ($married ne '') {
	    return "$last (now $married), $first";
	} else {
	    return "$last, $first";
	}
    }
}


sub inorder_fullname {
    package aid_util;

    local($first,$last,$married) = @_;

    if ($first eq '') {
	return $last;
    } else {
	if ($married ne '') {
	    return "$first $last (now $married)";
	} else {
	    return "$first $last";
	}
    }
}


sub affiliate {
    package aid_util;

    local($year, $school,$do_html_p) = @_;
    local($affil,$len);

    $affil = '  ';
    $len   = 2;

    if ($year =~ /^\d+$/) {
	$affil .= "<a href=\"" . $config{'master_path'} . 
	    "class/${year}.html\">" if $do_html_p;

	$year %= 100;
	if ($school eq 'Awalt') {
	    $affil  .= "A'$year";
	    $len    += length("A'$year");
	} elsif ($school eq 'MVHS' || $school eq '') {
	    $affil  .= "'$year";
	    $len    += length("'$year");
	} else {
	    $affil  .= "$school '$year";
	    $len    += length("$school '$year");
	}

	$affil .= "</a>" if $do_html_p;

    } else {
	$affil .= "<a href=\"" . $config{'master_path'} . 
	    "class/other.html\">" if $do_html_p;
	$affil .= "[$school $year]";
	$len   += length("[$school $year]");
	$affil .= "</a>" if $do_html_p;
    }

    return ($affil,$len);
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

    return $name;
}


sub aid_parse {
    package aid_util;

    local($[) = 0;
    local($_) = @_;
    local($time,$id,$req,$last,$first,$married,$school,
	  $year,$email,$homepage,$location) = split(/;/);
    local($mangledLast,$mangledFirst,$alias);

    $mangledLast = &main'mangle($last);   #' font-lock
    $mangledFirst = &main'mangle($first); #' font-lock

    $alias = substr($mangledFirst, 0, 1) . substr($mangledLast, 0, 7);
    $alias = "\L$alias\E";

    if ($aid_aliases{$alias} > 0) {
        $aid_aliases{$alias}++;
        $alias = substr($alias, 0, 7) . $aid_aliases{$alias};
    } else {
        $aid_aliases{$alias} = 1;
    }

    return ($time,$id,$req,$last,$first,$married,
	    $school,$year,$email,$alias,$homepage,$location);
}


sub aid_create_db {
    package aid_util;

    local($filename) = @_;
    local($[) = 0;
    local($_);
    local(@db, @result, *INFILE);

    open(INFILE,$filename) || die "Can't open $filename: $!\n";
    while(<INFILE>) {
	chop;
	$db[(split(/;/))[1]] = $_;
    }
    close(INFILE);
    
    return @db;
}


sub aid_get_usertext {
    package aid_util;

    local($id) = @_;
    local($[) = 0;
    local($_);
    local($text,$inFile,*TEXTFILE);

    $text = '';
    $inFile = $config{'newsdir'} . "${id}.txt";

    if (-r $inFile) {
	open(TEXTFILE,$inFile) || die "Can't open $inFile: $!\n";
	while(<TEXTFILE>) { $text .= $_; }
	close(TEXTFILE);
    }
    
    return $text;
}


sub submit_body {
    require 'tableheader.pl';
    package aid_util;

    local($[) = 0;
    local($_);
    local($tableh);
    local($star) = "<font color=\"#ff0000\">*</font>";
    local($rawdata,$message,$interactivep,$blank) = @_;
    local($mvhs_checked,$awalt_checked,$other_checked) = ('', '', '');
    local($time,$id,$req,$last,$first,$married,
	  $school,$year,$email,$homepage,$location) = split(/;/, $rawdata);
    local(@reqchk,$i);

    $homepage = 'http://' if $homepage eq '';

    for ($i = 0; $i < 3; $i++) {
	$reqchk[$i] = ($req == $i) ? ' checked' : '';
    }

    if ($school eq 'MVHS' || $school eq '') {
	$mvhs_checked = ' checked';
	$school = '';
    } elsif ($school eq 'Awalt') {
	$awalt_checked = ' checked';
	$school = '';
    } else {
	$other_checked = ' checked';
	$school = '' if $school eq 'Other';
    }

    if ($id != -1) {
	$tableh = 
	    &main'tableheader("Update Your Directory Listing", 
                              1, "ffff99", "000000", 1);
	$tableh .= "\n<p>Please update the following information";
	$tableh .= " and hit the <strong>Next&nbsp;&gt;</strong> button.</p>\n\n";
	$tableh .= "<p>Fields marked with a <font color=\"#ff0000\">*</font>";
	$tableh .= " are required.  All other fields are optional.</p>\n\n";

    } else {
	$tableh =
	    &main'tableheader("Add a Listing to the Directory",
                              1, "ffff99", "000000", 1);

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

    if ($interactivep && $blank) {
	$tableh .= "<p><font color=\"#ff0000\"><strong>You left one or more ";
	$tableh .= "required fields blank.\nPlease fill them in below ";
	$tableh .= "and resubmit.</strong></font></p>\n\n";
    }
	
    return "<br>\n" . $tableh . "
<form method=post action=\"" . $config{'cgi_path'} . "\"> 
<table border=0>
<tr><td>
<table border=0 width=\"100%\">
<tr><td bgcolor=\"#ffffcc\"><table border=0 cellspacing=7>
<tr>
  <td valign=top><font color=\"#000000\">First Name</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"first\" size=35 
  value=\"$first\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#000000\">Last/Maiden Name</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"last\" size=35
  value=\"$last\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#000000\">Married Name</font><br>
  <font color=\"#000000\" size=\"-1\">(if different from Maiden Name)</font></td>
  <td valign=top><input type=text name=\"married\" size=35
  value=\"$married\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#000000\">High School</font></td>
  <td>$star</td>
  <td valign=top><input type=radio name=\"school\"
  value=\"MVHS\"$mvhs_checked><font color=\"#000000\">&nbsp;MVHS&nbsp;&nbsp;&nbsp;&nbsp;<input
  type=radio name=\"school\" value=\"Awalt\"$awalt_checked>&nbsp;Awalt</font></td>
</tr>
<tr>
  <td valign=top>&nbsp;</td>
  <td valign=top>&nbsp;</td>
  <td valign=top><input type=radio name=\"school\" 
  value=\"Other\"$other_checked><font color=\"#000000\">&nbsp;Other:&nbsp;</font><input type=text
  name=\"sch_other\" size=27 value=\"$school\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#000000\">Graduation year or affiliation</font><br>
  <font color=\"#000000\" size=\"-1\">(such as 1993, 2001, or Teacher)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"grad\" size=35
  value=\"$year\"></td>
</tr>
<tr>
  <td valign=top><font color=\"#000000\">E-mail address</font><br>
  <font color=\"#000000\" size=\"-1\">(such as albert\@aol.com)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"mail\" size=35
  value=\"$email\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#000000\">Web Page</font></td>
  <td valign=top><input type=text name=\"homepage\" size=35
  value=\"$homepage\"></td>
</tr>
<tr>
  <td colspan=2 valign=top><font color=\"#000000\">Location</font><br>
  <font color=\"#000000\" size=\"-1\">(city, school, or company)</font></td>
  <td valign=top><input type=text name=\"location\" size=35
  value=\"$location\"></td>
</tr>
<tr>
  <td colspan=3><font color=\"#000000\">
  <br><strong>What's New?</strong> (Beta) Tell us, in 100 words or less, what
  you've been up to recently.</font>
  <img src=\"" . $config{'master_path'} .
  "new.gif\" alt=\"[new]\" width=\"28\" height=\"11\"><br>
  <textarea name=\"message\" rows=10 cols=55 wrap>$message</textarea>
  </td>
</tr>
<tr>
  <td colspan=3><font color=\"#000000\"><br>Please 
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
<input type=\"hidden\" name=\"id\" value=\"$id\">
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
	warn "cannot send mail\n";
    }
}


sub message_footer {
    package aid_util;

    return "\n--\n" . 
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
    local($rawdata,$message,$show_req_p,$do_html_p,$do_vcard_p) = @_;
    local($time,$id,$req,$last,$first,$married,
	  $school,$year,$email,$homepage,$location) = split(/;/, $rawdata);

    $do_vcard_p = 0 unless defined($do_vcard_p);

    $retval .= "<table border=0 cellpadding=6><tr><td bgcolor=\"#ffffcc\"><font color=\"#000000\"><pre>\n\n" if $do_html_p;
    $retval .= "First Name         : ";
    $retval .= ($first eq '') ? "\n" : 
	((($do_html_p) ? "<strong>" : "") .
	 $first . 
	 (($do_html_p) ? "</strong>" : "") .
	 "\n");
    
    $retval .= "Last/Maiden Name   : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $last;
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Married Name       : ";
    $retval .= ($married eq '') ? "(same as last name)\n" :
	((($do_html_p) ? "<strong>" : "") .
	 $married . 
	 (($do_html_p) ? "</strong>" : "") .
	 "\n");
    
    $retval .= "\n";
    $retval .= "School             : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $school;
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Grad. Year         : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $year;
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";

    $retval .= "\n";
    $retval .= "Email              : ";
    $retval .= "<strong><a href=\"mailto:$email\">" if $do_html_p;
    $retval .= $email;
    $retval .= "</a></strong>" if $do_html_p;
    $retval .= "\n";

    $retval .= "Web Page           : ";
    $retval .= ($homepage eq '') ? "(none)\n" :
	((($do_html_p) ? "<strong><a href=\"$homepage\">" : "") .
	 $homepage . 
	 (($do_html_p) ? "</a></strong>" : "") .
	 "\n");

    $retval .= "Location           : ";
    $retval .= ($location eq '') ? "(none provided)\n" :
	((($do_html_p) ? "<strong>" : "") .
	 $location .
	 (($do_html_p) ? "</strong>" : "") .
	 "\n");

    if ($do_vcard_p && $do_html_p) {
	$retval .= "vCard              : ";
	$retval .= "<a href=\"$config{'cgi_path'}/vcard/${id}.vcf\">";
	$retval .= "<img src=\"$config{'master_path'}vcard.gif\" ";
	$retval .= "height=32 width=32 border=0 align=top ";
	$retval .= "alt=\"[vCard]\"></a>\n";
    }

    if ($show_req_p) {
	$retval .= "\n";
	$retval .= "Send Email Updates : ";
	$retval .= ($req == 2) ? "yes (sorted by graduating class)\n" :
	    ($req == 1) ? "yes (sorted by name)\n" : "no\n";
    } 

    if ($time ne '') {
	$retval .= "\n";
	$retval .= "Last Updated       : ";
	$retval .= &main'ctime($time);
    }

    $message = &main'aid_get_usertext($id) if $message eq '';  #' fnt
    if ($message ne '') {
	$retval .= "\n";
	$retval .= "What's New? (beta) :\n";
	$retval .= "</pre>\n" if $do_html_p;
	$retval .= $do_html_p ? "<blockquote>\n" : "\"";
	$retval .= $message;
	$retval .= $do_html_p ? "\n</blockquote>\n" : "\"\n";
    } else {
	$retval .= "</pre>\n" if $do_html_p;
    }

    $retval .= "</font></td></tr></table>\n" if $do_html_p;

    if ($do_html_p && $time ne '') {
	$retval .= &main'modify_button($id,
	    &main'inorder_fullname($first,$last,$married));
    }

    return $retval;
}

sub modify_button {
    package aid_util;

    local($id,$name) = @_;
    local($cgi) = $config{'cgi_path'};

    return "
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


sub common_html_ftr {
    package aid_util;

    local($page) = @_;
    local($rcsid) = "<!-- " . $config{'rcsid'} . " -->";
    local($ftr);

    $ftr = "
<!-- begin common_html_ftr -->
$rcsid

<hr noshade size=1>
<p align=center><font size=\"-1\">";

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
    
    $ftr .= "
<blockquote><a name=\"disclaimer\">Acceptable use</a>: this directory is
provided solely for the information of alumni of Mountain View High
School and Awalt High School.  Any solicitation of business,
information, contributions or other response from individuals listed in
this publication is forbidden.</blockquote>

<hr noshade size=1>

<p><a href=\"" . $config{'admin_url'} .
"\"><em>" . $config{'admin_name'} . "</em></a><em>,</em> <a 
href=\"mailto:" . $config{'admin_email'} . 
"\"><tt>" . $config{'admin_email'} . "</tt></a></p>

<!-- end common_html_ftr -->

</body>
</html>
";

    return $ftr;
}


sub common_html_hdr {
    require 'ctime.pl';
    package aid_util;

    local($page,$norobots) = @_;
    local($h1, $h2, $h3, $h4, $html_head);
    local($name, $url);
    local($timestamp);
    local($rcsid) = "<!-- " . $config{'rcsid'} . " -->";

    $timestamp = ($page == 0) ? 'Last update to Directory: ' :
	'Last update to this page: ';

    $h1 = "<body bgcolor=\"#ffffff\" link=\"#0000cc\" text=\"#000000\" vlink=\"#990099\">
<hr noshade size=1>
<table border=0 cellpadding=5 cellspacing=0 width=\"100%\">
<tr>
  <td bgcolor=\"#ffffcc\" valign=top align=left rowspan=2><font size=\"-1\">";

    $h2 = "";
    foreach $idx (0 .. $#page_idx) {
	($name, $url) = split(/,/, $page_idx[$idx]);
        if ($idx == $page) {
	    $h2 .= "\n  <font color=\"#000000\"><strong>$name</strong></font>";
        } else {
            $h2 .= "<a\n  href=\"$url\">$name</a>";
        }
	$h2 .= "<br>" unless $idx == $#page_idx;
    }
    $h2 .= "</font></td>\n";

    $h2 .= "  <td bgcolor=\"#ffffcc\" valign=top align=left rowspan=2><font size=\"-1\"><br>";
    foreach $idx (0 .. $#second_idx) {
	($name, $url) = split(/,/, $second_idx[$idx]);
        if ($idx == ($page - 10)) {
	    $h2 .= "\n  <font color=\"#000000\"><strong>$name</strong></font>";
        } else {
            $h2 .= "<a\n  href=\"$url\">$name</a>";
        }
	$h2 .= "<br>" unless $idx == $#second_idx;
    }
    $h2 .= "</font></td>\n";

    $h3 = "  <td align=right valign=top bgcolor=\"#ffffcc\">&nbsp;<a href=\""
  . $config{'master_path'} . "\"><img
  src=\"" . $config{'master_path'} . "title.gif\"
  alt=\"Mountain View High School Alumni Internet Directory\"
  align=bottom width=398 height=48 border=0></a></td>
</tr>
<tr>
  <td align=right valign=bottom bgcolor=\"#ffffcc\"><font size=\"-1\"
  color=\"#000000\"><i>$timestamp" . &main'ctime(time) . "</i></font>
  </td>
</tr>
</table>
<hr noshade size=1>
<!-- discourage www.roverbot.com --><!--BAD-DOG-->

";

    $html_head = "<html>\n<head>\n" .
	"<title>Mountain View High School Alumni Internet Directory" .
	"</title>\n" . $site_tags . "\n" . $pics_label . "\n";
    $html_head .= "$noindex\n" if $norobots;
    $html_head .= "</head>\n\n";
    
    return $html_head .
	"<!-- begin common_html_hdr -->\n$rcsid\n" .
        $h1 . $h2 . $h3 .
        "<!-- end common_html_hdr -->\n";
}

1;

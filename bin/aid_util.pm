#
#     FILE: mv_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the MVHS Alumni Internet Directory
#      $Id: mv_util.pl,v 1.47 1997/10/16 21:21:24 mjr Exp mjr $
#

CONFIG: {
    package mv_util;

    # divcom.umop-ap.com configuration
    %config =
	('admin_name',   "Michael John Radwin",
	 'admin_email',  "mjr\@acm.org",
	 'admin_school', "Mountain View High School, Class of '93",
	 'admin_phone',  "408-536-2554",
	 'admin_url',    "http://umop-ap.com/~mjr/",
	 'master_srv',   "umop-ap.com",
	 'master_path',  "/~mjr/mvhs/",
	 'cgi_path',     "/cgi-bin/cgiwrap/mjr/mvhsaid",
	 'index_page',	 "index.html",
	 'wwwdir',       "/home/divcom/mjr/public_html/mvhs/",
	 'mvhsdir',      "/home/divcom/mjr/mvhs/",
	 'sendmail',     "/usr/lib/sendmail",
	 'mailprog',     "/usr/ucb/mail",
	 'mailto',       "mjr\@divcom",
	 'mailsubj',	 "MVHSAID"
	  );

    # foo.metamorphosis.net configuration
#    %config =
#        ('admin_name',   "Michael John Radwin",
#         'admin_email',  "mjr\@acm.org",
#         'admin_school', "Mountain View High School, Class of '93",
#         'admin_phone',  "408-536-2554",
#         'admin_url',    "http://umop-ap.com/~mjr/",
#	 'master_srv',   "metamorphosis.net",
#	 'master_path',  "/~mjr/mvhs/",
#         'cgi_path',     "/~mjr/cgi-bin/mvhsaid.cgi",
#         'index_page',   "index.html",
#         'wwwdir',       "/home/mjr/public_html/mvhs/",
#         'mvhsdir',      "/home/mjr/mvhs/",
#         'sendmail',     "/usr/sbin/sendmail",
#         'mailprog',     "/usr/bin/mail",
#         'mailto',       "mjr\@foo",
#         'mailsubj',     "MVHSAID"
#	 );

    @page_idx = 
	("Home,"                  . $config{'master_path'},
	 "Alphabetically,"        . $config{'master_path'} . "all.html",
	 "Grad.&nbsp;Class,"      . $config{'master_path'} . "class.html",
	 "Recent&nbsp;Additions," . $config{'master_path'} . "recent.html",
	 "Web&nbsp;Pages,"        . $config{'master_path'} . "pages.html",
	 "Get&nbsp;Listed!,"      . $config{'master_path'} . "add.html",
	 "Acceptable&nbsp;Use,#disclaimer");

    @second_idx = 
	("Listings,"              . $config{'master_path'} . "listings.html",
	 "Reunions,"              . $config{'master_path'} . "reunions.html",
	 "Links,"                 . $config{'master_path'} . "links.html",
	 "Nicknames,"             . $config{'master_path'} . "nicknames.html",
	 "Tech&nbsp;Notes,"       . $config{'master_path'} . "tech.html");

    $pics_label = "<meta http-equiv=\"PICS-Label\" content='(PICS-1.1 \"http://www.rsac.org/ratingsv01.html\" l gen true comment \"RSACi North America Server\" by \"" . $config{'admin_email'} . "\" for \"http://" . $config{'master_srv'} . $config{'master_path'} . "\" on \"1996.04.04T08:15-0500\" r (n 0 s 0 v 0 l 0))'>";

    $site_tags = "<meta name=\"keywords\" content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">\n<meta name=\"description\" content=\"email/web page listing of alumni, students, faculty and staff from Mountain View High School in Mountain View, California.  Also catalogues alumni from Chester F. Awalt High School, which was merged with MVHS in the early 80's.\">";

    $noindex = "<meta name=\"robots\" content=\"noindex,nofollow\">";

    %mv_aliases = ();   # global alias hash repository

    1;
}

# give 'em back the configuration variable they need
sub mv_config {
    package mv_util;

    die "NO CONFIG $_[0]!\n" if !defined($config{$_[0]});
    return $config{$_[0]};
}


# is the GMT less than one month ago?
sub is_new {
    package mv_util;

    return ((time - $_[0]) < 2419200) ? 1 : 0;
}


sub fullname {
    package mv_util;

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
    package mv_util;

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
    package mv_util;
    local($year, $school) = @_;
    local($affil);

    if ($year =~ /^\d+$/) {
	$affil  = "  $school '$year";
	$affil  = "  A'$year" if $school eq 'Awalt';
	$affil  = "  '$year"  if $school eq 'MVHS' || $school eq '';

    } else {
	$affil  = "  [$school $year]";
    }

    return $affil;
}


# remove punctuation, hyphens, parentheses, and quotes.
sub mangle {
    package mv_util;
    local($name) = @_;

    $name =~ s/\.//g;
    $name =~ s/\s//g;
    $name =~ s/-//g;
    $name =~ s/\".*\"//g;
    $name =~ s/\(.*\)//g;
    $name =~ s/\'.*\'//g;

    return $name;
}


sub mv_parse {
    local($[) = 0;
    local($_) = @_;
    local($time,$id,$req,$last,$first,$married,$school,
	  $year,$email,$homepage,$location) = split(/;/);
    local($mangledLast,$mangledFirst,$alias);

    $mangledLast = &'mangle($last);   #' font-lock
    $mangledFirst = &'mangle($first); #' font-lock

    $alias = substr($mangledFirst, 0, 1) . substr($mangledLast, 0, 7);
    $alias = "\L$alias\E";

    if ($mv_aliases{$alias} > 0) {
        $mv_aliases{$alias}++;
        $alias = substr($alias, 0, 7) . $mv_aliases{$alias};
    } else {
        $mv_aliases{$alias} = 1;
    }

    return ($time,$id,$req,$last,$first,$married,
	    $school,$year,$email,$alias,$homepage,$location);
}


sub mv_create_db {
    package mv_util;

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


sub submit_body {
    package mv_util;
    require 'tableheader.pl';

    local($[) = 0;
    local($_);
    local($tableh);
    local($star) = "<font color=\"#ff0000\">*</font>";
    local($rawdata,$interactivep,$blank) = @_;
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
	    &tableheader("Update Your Directory Listing", 1, "ffff99", 1);
	$tableh .= "\n<p>Please update the following information";
	$tableh .= " and hit the <strong>Submit</strong> button.\nYour submission will be";
	$tableh .= " processed in a day or so.</p>\n\n";
	$tableh .= "<p>Fields marked with a <font color=\"#ff0000\">*</font>";
	$tableh .= " are required.  All other fields are optional.";

    } else {
	$tableh =
	    &tableheader("Add a Listing to the Directory", 1, "ffff99", 1);

	$tableh .= "\n<p>Thanks for adding a name to the MVHS Alumni Internet
Directory!  To update your entry, please see the <a
href=\"" . $config{'cgi_path'} . "?update\">update page</a>.  To add a new
entry, please enter the following information and hit the
<strong>Submit</strong> button.
Your submission will be processed in a day or so.</p>

<p>Fields marked with a $star are required.
All other fields are optional.";
    }

    if ($interactivep && $blank) {
	$tableh .= "\n<font color=\"#ff0000\"><strong>You left one or more";
	$tableh .= " required fields blank.  Please fill them in below";
	$tableh .= " and resubmit.</strong></font>";
    }
	
    $tableh .= "</p>\n\n";

    
    return "<br>\n" . $tableh . "
<form method=post action=\"" . $config{'cgi_path'} . "\"> 
<table border=0>
<tr><td bgcolor=\"#ffffcc\"><table border=0 cellspacing=7>
<tr>
  <td valign=top>First Name</td>
  <td>$star</td>
  <td valign=top><input type=text name=\"first\" size=35 
  value=\"$first\"></td>
</tr>
<tr>
  <td valign=top>Last/Maiden Name</td>
  <td>$star</td>
  <td valign=top><input type=text name=\"last\" size=35
  value=\"$last\"></td>
</tr>
<tr>
  <td colspan=2 valign=top>Married Name<br>
  <font size=\"-1\">(if different from Maiden Name)</font></td>
  <td valign=top><input type=text name=\"married\" size=35
  value=\"$married\"></td>
</tr>
<tr>
  <td valign=top>High School</td>
  <td>$star</td>
  <td valign=top><input type=radio name=\"school\"
  value=\"MVHS\"$mvhs_checked>&nbsp;MVHS&nbsp;&nbsp;&nbsp;&nbsp;<input
  type=radio name=\"school\" value=\"Awalt\"$awalt_checked>&nbsp;Awalt</td>
</tr>
<tr>
  <td valign=top>&nbsp;</td>
  <td valign=top>&nbsp;</td>
  <td valign=top><input type=radio name=\"school\" 
  value=\"Other\"$other_checked>&nbsp;Other:&nbsp;<input type=text
  name=\"sch_other\" size=27 value=\"$school\"></td>
</tr>
<tr>
  <td valign=top>Graduation year or affiliation<br>
  <font size=\"-1\">(such as 93, 87, or Teacher)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"grad\" size=35
  value=\"$year\"></td>
</tr>
<tr>
  <td valign=top>E-mail address<br>
  <font size=\"-1\">(such as albert@aol.com)</font></td>
  <td>$star</td>
  <td valign=top><input type=text name=\"mail\" size=35
  value=\"$email\"></td>
</tr>
<tr>
  <td colspan=2 valign=top>Web Page</td>
  <td valign=top><input type=text name=\"homepage\" size=35
  value=\"$homepage\"></td>
</tr>
<tr>
  <td colspan=2 valign=top>Location<br>
  <font size=\"-1\">(city, school, or company)</font></td>
  <td valign=top><input type=text name=\"location\" size=35
  value=\"$location\"></td>
</tr>
<tr>
  <td colspan=3><br>
  Please send an updated copy of the Directory to my
  email address every 3-4 months:<br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\"
  value=\"1\"$reqchk[1]>&nbsp;&nbsp;Sorted by name.<br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\" 
  value=\"2\"$reqchk[2]>&nbsp;&nbsp;Sorted by graduating class.<br>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"request\"
  value=\"0\"$reqchk[0]>&nbsp;&nbsp;No, please do not send me copies
  of the Directory.
  </td>
</tr>
</table>
</td></tr></table>
<input type=\"submit\" value=\"Submit entry\">
<input type=\"reset\" value=\"Reset form\">
<input type=\"hidden\" name=\"id\" value=\"$id\">
</form>

";

}


sub sendmail {
    package mv_util;

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
    package mv_util;

    return "\n--\n" . 
	$config{'admin_name'} . "\n" .
	$config{'admin_school'} . "\n\n" .
	"Email     : " . $config{'admin_email'} . "\n" .
	"WWW       : " . $config{'admin_url'} . "\n" .
	"Phone     : " . $config{'admin_phone'};
}

# uhhh... looks like I don't truly get perl4's packaging.
sub today {
    package mv_util;
    require 'ctime.pl';

    local($today) = &ctime(time);
    chop $today;
    return $today;
}

sub about_text {
    package mv_util;
    require 'ctime.pl';

    local($retval) = '';
    local($rawdata,$show_req_p,$do_html_p,$do_vcard_p) = @_;
    local($time,$id,$req,$last,$first,$married,
	  $school,$year,$email,$homepage,$location) = split(/;/, $rawdata);

    $do_vcard_p = 0 unless defined($do_vcard_p);

    $retval .= "<pre>\n" if $do_html_p;
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
	$retval .= "<a href=\"$config{'cgi_path'}?vcard=$id\">";
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
	$retval .= do ctime($time);
    }


    $retval .= "</pre>\n" if $do_html_p;

    if ($do_html_p && $time ne '') {
	$retval .= &'modify_html($id,&'inorder_fullname($first,$last,$married));
    }

    return $retval;
}

sub modify_html {
    package mv_util;

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
    package mv_util;

    local($page) = @_;
    local($ftr);

    $ftr = "
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
    $ftr .= "<br>\n";
    foreach $idx (0 .. $#second_idx) {
	($name, $url) = split(/,/, $second_idx[$idx]);
        if ($idx == ($page - 10)) {
	    $ftr .= "\n  <strong>$name</strong>";
        } else {
            $ftr .= "<a\n  href=\"$url\">$name</a>";
        }
	$ftr .= " || " unless $idx == $#second_idx;
    }
    $ftr .= "</font></p>\n";
    
    return $ftr . "

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
</body>
</html>
";

}


sub common_html_hdr {
    package mv_util;
    require 'ctime.pl';

    local($page,$norobots) = @_;
    local($h1, $h2, $h3, $h4, $html_head);
    local($name, $url);
    local($timestamp);

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
	    $h2 .= "\n  <strong>$name</strong>";
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
	    $h2 .= "\n  <strong>$name</strong>";
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
  color=\"#000000\"><i>$timestamp" . &ctime(time) . "</i></font>
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

    return $html_head . $h1 . $h2 . $h3;
}


1;


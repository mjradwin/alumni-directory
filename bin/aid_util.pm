#
#     FILE: mv_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the MVHS Alumni Internet Directory
#      $Id: tableheader.pl,v 1.1 1996/11/23 17:47:15 mjr Exp $
#

CONFIG: {
    package mv_util;

    # BrownCS configuration
    %config = ('admin_email', "mjr\@cs.brown.edu",
	       'admin_url',   "http://www.cs.brown.edu/people/mjr/",
	       'master_url',  "http://www.cs.brown.edu/people/mjr/mvhs/",
	       'cgi_url',     "http://www.cs.brown.edu/cgi-bin/mjr-mvhs.cgi",
	       'wwwdir',      "/pro/web/web/people/mjr/mvhs/",
	       'mvhsdir',     "/home/mjr/doc/mvhs/",
	       'cgi_path',     "/cgi-bin/mjr-mvhs.cgi");

    # divcom configuration
#     %config = ('admin_email', "mjr\@acm.org",
# 	       'admin_url',   "http://umop-ap.com/~mjr/",
# 	       'master_url',  "http://umop-ap.com/~mjr/mvhs/",
# 	       'cgi_url',     "http://umop-ap.com/~mjr/mvhs/cgi-bin/mvhsaid",
# 	       'wwwdir',      "/home/divcom/mjr/public_html/mvhs/",
# 	       'mvhsdir',     "/home/divcom/mjr/mvhs/",
#	       'cgi_path',    "/~mjr/mvhs/cgi-bin/mvhsaid");

    @page_idx = ('Home,./',
		 'Alphabetically,all.html',
		 'Grad.&nbsp;Class,class.html',
		 'Recent&nbsp;Additions,recent.html',
		 'Web&nbsp;Pages,pages.html',
		 'Get&nbsp;Listed!,add.html',
		 'Acceptible&nbsp;Use,#disclaimer');

    $pics_label = "<meta http-equiv=\"PICS-Label\" content='(PICS-1.0 \"http://www.rsac.org/ratingsv01.html\" l gen true comment \"RSACi North America Server\" by \"" . $config{'admin_email'} . "\" for \"" . $config{'master_url'} . "\" on \"1996.04.04T08:15-0500\" exp \"1997.07.01T08:15-0500\" r (n 0 s 0 v 0 l 0))'>";

    $site_tags = "<meta name=\"keywords\" content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">\n<meta name=\"description\" content=\"Mountain View High School Internet Directory: email address and web page listing of alumni, students, faculty and staff.  Also Awalt High School\">";

    $html_head = "<html>\n<head>\n" .
	"<title>Mountain View High School Alumni Internet Directory</title>\n" .
	$site_tags . "\n" . $pics_label . "\n</head>\n\n";

    1;
}

# give 'em back the configuration variable they need
sub mv_config {
    package mv_util;

    die if !defined($config{$_[0]});
    return $config{$_[0]};
}

# is the GMT less than one month ago?
sub is_new {
    package mv_util;

    return ((time - $_[0]) < 2419200) ? 1 : 0;
}

sub cannonize_email {
    package mv_util;
    local($usr, $dom) = split(/\@/, $_[0]);
    return $usr . '@' . "\L$dom\E";
}


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
    package mv_util;

    local($[) = 0;
    local($_) = @_;
    local($time,$id,$req,$last,$first,$school,$year,$email,@homepg) = split(/:/);
    local($homepage, $mangledLast, $mangledFirst, $alias);
    $homepage = join(':', @homepg);

    $mangledLast = &'mangle($last);
    $mangledFirst = &'mangle($first);

    $alias = substr($mangledFirst, 0, 1) . substr($mangledLast, 0, 7);
    $alias = "\L$alias\E";

    return ($time,$id,$req,$last,$first,$school,$year,$email,$alias,$homepage);
}

sub mv_old_parse {
    package mv_util;

    local($[) = 0;
    local($_) = @_;
    local($last, $first, $school, $year, $email, @homepg) = split(/:/);
    local($homepage, $mangledLast, $mangledFirst, $alias);
    $homepage = join(':', @homepg);

    $mangledLast = &'mangle($last);
    $mangledFirst = &'mangle($first);

    $alias = substr($mangledFirst, 0, 1) . substr($mangledLast, 0, 7);
    $alias = "\L$alias\E";

    return ($last, $first, $school, $year, $email, $alias, $homepage);
}

sub bydatakeys { $datakeys[$a] cmp $datakeys[$b] }
sub mv_alpha_db {
    package mv_util;

    local(@db) = &'mv_create_db($_[0]);
    local(@alpha, @fields);
    @datakeys = ();

    foreach (@db) {
	@fields = &'mv_parse($_);
	push(@datakeys, "$fields[3]:$fields[4]");
    }
    @alpha = @db[sort bydatakeys $[..$#db];
    return @alpha;
}


# index on uid
sub mv_create_db {
    package mv_util;

    local($filename) = @_;
    local($[) = 0;
    local($_);
    local(@db, @result, *INFILE);

    open(INFILE,$filename) || die "Can't open $filename: $!\n";
    while(<INFILE>) {
	chop;
	@result = &'mv_parse($_); #'  (let the font-lock be unconfused)
	$db[$result[1]] = $_;
    }
    close(INFILE);
    
    return @db;
}

sub submit_body {
    package mv_util;
    require 'tableheader.pl';

    local($[) = 0;
    local($_);
    local($time,$id,$req,$last,$first,$school,$year,$email,$alias,$homepage) 
	= &'mv_parse($_[0]); #' font-lock

    $homepage = 'http://' if $homepage eq '';
    $req = ($req) ? ' checked' : '';

    return "<br>\n" . 
	&tableheader("Add a Listing to the Directory", 1, 'ffff99', 1) . 
"<p>Thanks for adding a name to the MVHS Alumni Internet
Directory!  To update your entry, please see the <a
href=\"" . $config{'cgi_path'} . "?update\">update page</a>.  To add a new
entry, please enter the following information and hit the submit button.
Your submission will be processed in a day or so.</p>

<form method=post action=\"" . $config{'cgi_path'} . "\"> 
<table border=0 cellspacing=10>
<tr>
  <td><strong>Full Name</strong><br><em>(i.e. Smith, Chester)</em></td>
  <td><input type=text name=\"last\" size=\"17\"
    value=\"$last\"> ,<br><font size=\"-1\">Last</font></td>
  <td><input type=text name=\"first\" size=\"17\"
      value=\"$first\"><br><font size=\"-1\">First</font></td>
</tr>
<tr>
  <td><strong>E-mail
      address</strong><br><em>(i.e. cfs\@some.edu)</em></td>
  <td colspan=2><input type=text name=\"mail\" size=\"40\"
      value=\"$email\"><br></td>
</tr>
<tr>
  <td><strong>WWW home page</strong> (if
      any)<br><em>(i.e. http://some.edu/~cfs/)</em></td>
  <td colspan=2><input type=text name=\"homepage\" size=\"40\"
      value=\"$homepage\"><br></td>
</tr>
<tr>
  <td><strong>High School</strong><br><em>(MVHS or Awalt)</em></td>
  <td colspan=2><input type=text name=\"school\" size=\"10\" 
      value=\"$school\"><br></td>
</tr>
<tr>
  <td><strong>Graduation year</strong> or affiliation<br><em>(e.g. 1993,
      87)</em></td>
  <td colspan=2><input type=text name=\"grad\" size=\"10\"
      value=\"$year\"><br></td>
</tr>
<tr>
  <td colspan=3><input type=checkbox name=\"request\"$req> Please send
  me updated alumni addresses through email.</td>
</tr>
<input type=\"hidden\" name=\"id\" value=\"$id\">
</table>

<P>
<input type=\"submit\" value=\"Submit entry\">
<input type=\"reset\" value=\"Reset form\">
</form>

";
}

sub common_html_ftr {
    package mv_util;

    local($page) = @_;
    local($ftr);

    $ftr = "
<hr noshade size=1>
<p align=center>[ <font size=\"-1\" 
  face=\"Arial, Helvetica, MS Sans Serif\">";

    foreach $idx (0 .. $#page_idx) {
	($name, $url) = split(/,/, $page_idx[$idx]);
        if ($idx == $page) {
	    $ftr .= "\n  <strong>$name</strong>";
        } else {
            $ftr .= "<a\n  href=\"$url\">$name</a>";
        }
	$ftr .= " | " unless $idx == $#page_idx;
    }
    $ftr .= "</font> ]</p>\n";
    
    return $ftr . "
<blockquote><a name=\"disclaimer\">This</a> address list is provided
solely for the information of alumni of Mountain View High School and
Awalt High School.  Any solicitation of business, information,
contributions or other response from individuals listed in this
publication is forbidden.</blockquote>
<hr noshade size=1>

<p><a href=\"" . $config{'admin_url'} .
"\"><em>Michael J. Radwin</em></a><em>,</em> <a 
href=\"mailto:" . $config{'admin_email'} . 
"\"><tt>" . $config{'admin_email'} . "</tt></a></p>
</body>
</html>
";

}

sub common_html_hdr {
    package mv_util;

    local($page, $page_name) = @_;
    local($h1, $h2, $h3, $h4);
    local($name, $url);
    local($today);

#    ($page_name) = split(/,/, $page_idx[$page]) unless $page_name;
#    $page_name =~ s/&nbsp;/ /g;
    $today = localtime;

    $h1 = "<body bgcolor=\"#ffffff\" LINK=\"#000099\" TEXT=\"#000000\" VLINK=\"#990099\">
<hr noshade size=1>
<table border=0 cellpadding=8 cellspacing=0 width=\"100%\">
<tr>
  <td bgcolor=\"#ffffcc\" align=left rowspan=2><font size=\"-1\"
  face=\"Arial, Helvetica, MS Sans Serif\">";

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
    $h2 .= "</font>\n  </td>\n";

    $h3 = "  <td align=right valign=top bgcolor=\"#ffffcc\"><a href=\"./\"><img
  src=\"title.gif\"
  alt=\"Mountain View High School Alumni Internet Directory\"
  align=bottom width=398 height=48 border=0></a>
  </td>
</tr>
<tr>
  <td align=right valign=bottom bgcolor=\"#ffffcc\"><font size=\"-1\"
  color=\"#000000\"><i>This page generated: $today</i></font>
  </td>
</tr>
</table>
<hr noshade size=1>

";

    return $html_head . $h1 . $h2 . $h3;
}


1;


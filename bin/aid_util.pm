CONFIG: {
    package mv_util;

    @page_idx = ('Home,./',
		 'Alphabetically,all.html',
		 'Grad.&nbsp;Class,class.html',
		 'Recent&nbsp;Additions,recent.html',
		 'Web&nbsp;Pages,pages.html',
		 'Add&nbsp;Listing,add.html',
		 'Acceptible&nbsp;Use,#disclaimer');

    1;
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

    local(@db) = &mv_create_db($_[0]);
    local(@alpha, @fields);
    @datakeys = ();

    foreach (@db) {
	@fields = &mv_parse($_);
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

    local($[) = 0;
    local($_);
    local($time,$id,$req,$last,$first,$school,$year,$email,$alias,$homepage) 
	= &mv_parse($_[0]);

    $homepage = 'http://' if $homepage eq '';
    $req = ($req) ? ' checked' : '';

    return "<br>
<table cellspacing=0 cellpadding=1 border=0 width=\"100%\">
  <tr>
    <td bgcolor=\"#000000\" align=center>
    <table cellspacing=0 cellpadding=5 border=0 width=\"100%\">
      <tr>
        <td bgcolor=\"#eeee88\" align=center valign=middle>
        <strong><font size=\"+1\">A</font>&nbsp;D&nbsp;D&nbsp;&nbsp; A&nbsp;&nbsp; <font size=\"+1\">L</font>&nbsp;I&nbsp;S&nbsp;T&nbsp;I&nbsp;N&nbsp;G&nbsp;&nbsp; T&nbsp;O&nbsp;&nbsp; T&nbsp;H&nbsp;E&nbsp;&nbsp; <font size=\"+1\">D</font>&nbsp;I&nbsp;R&nbsp;E&nbsp;C&nbsp;T&nbsp;O&nbsp;R&nbsp;Y</strong>
        </td>
      </tr>
    </table>
    </td>
  </tr>
</table>

<p>Thanks for adding a name to the MVHS Alumni Internet
Directory!  To update your entry, please see the <a
href=\"/cgi-bin/mjr-mvhs.cgi?update\">update page</a>.  To add a new
entry, please enter the following information and hit the submit button.
Your submission will be processed in a day or so.</p>

<form method=post action=\"/cgi-bin/mjr-mvhs.cgi\"> 
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

    return "
<hr noshade size=1>
<blockquote><a name=\"disclaimer\">This</a> address list is provided
solely for the information of alumni of Mountain View High School and
Awalt High School.  Any solicitation of business, information,
contributions or other response from individuals listed in this
publication is forbidden.</blockquote>
<hr noshade size=1>

<p><a href=\"/people/mjr/\"><em>Michael J. Radwin</em></a><em>,</em> <a 
href=\"mailto:mjr\@cs.brown.edu\"><tt>mjr\@cs.brown.edu</tt></a></p>
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

    ($page_name) = split(/,/, $page_idx[$page]) unless $page_name;
    $page_name =~ s/&nbsp;/ /g;
    $today = localtime;

    $h1 = "<html>
<head>
<title>Mountain View High School Alumni Internet Directory</title>
<meta name=\"keywords\" content=\"Mountain View High School, Alumni, MVHS, Awalt High School, Mountain View, Los Altos, California, reunion, Radwin\">
<meta name=\"description\" content=\"Mountain View High School Internet Directory: email address and web page listing of alumni, students, faculty and staff.  Also Awalt High School\">
<meta http-equiv=\"PICS-Label\" content='(PICS-1.0 \"http://www.rsac.org/ratingsv01.html\" l gen true comment \"RSACi North America Server\" by \"mjr\@cs.brown.edu\" for \"http://www.cs.brown.edu/people/mjr/mvhs/\" on \"1996.04.16T08:15-0500\" exp \"1997.01.01T08:15-0500\" r (n 0 s 0 v 0 l 0))'>
</head>

<body bgcolor=\"#f0f0f0\" LINK=\"#000080\" TEXT=\"#000000\" VLINK=\"#800080\">
<hr noshade size=1>
<table border=0 cellpadding=8 cellspacing=0 width=\"100%\">
<tr>
  <td bgcolor=\"#eeeecc\" align=left rowspan=2><font size=\"-1\"
  face=\"Arial, Helvetica, MS Sans Serif\">";

#' (unconfuse da font-lock)

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

    $h3 = "  <td align=right valign=top bgcolor=\"#eeeecc\"><a href=\"./\"><img
  src=\"title.gif\" alt=\"Mountain View High School Alumni Internet
  Directory\" align=bottom width=398 height=48 border=0></a>
  </td>
</tr>
<tr>
  <td align=right valign=bottom bgcolor=\"#eeeecc\"><font size=\"-1\"
  color=\"#000000\"><i>This page generated: $today</i></font>
  </td>
</tr>
</table>
<hr noshade size=1>

";

    return $h1 . $h2 . $h3;
}


1;


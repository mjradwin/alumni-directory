#
#     FILE: aid_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the Alumni Internet Directory
#      $Id: aid_util.pl,v 4.57 1999/03/12 21:36:38 mradwin Exp mradwin $
#

$aid_util'rcsid =
 '$Id: aid_util.pl,v 4.57 1999/03/12 21:36:38 mradwin Exp mradwin $';

# ----------------------------------------------------------------------
# CONFIGURATION
#
# to revise the AID for another school, you should edit the 
# *aid_util'variables in this configuration section, and the
# subroutines submit_body() and affiliate()
# ----------------------------------------------------------------------

# since aid_config depends on caldate, do these first
@aid_util'MoY = #'#
    ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
$aid_util'caldate = &aid_caldate(time); #'#

require 'aid_config.pl';

@aid_util'req_descr_long =   #'#
    (
     'No e-mail except for yearly address verification.',
     'All alumni, sorted by name. [~ 65 kbytes]',
     'All alumni, sorted by graduating class. [~ 65 kbytes]',
     'Only new and changed alumni entries. [~ 15 kbytes]',
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
 "Alpha,"            . $aid_util'config{'master_path'} . "alpha/a-index.html",
 "Class,"            . $aid_util'config{'master_path'} . "class/",
 "Awalt,"            . $aid_util'config{'master_path'} . "class/awalt.html",
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
 "Stats,"      . $aid_util'config{'master_path'} . "etc/stats.txt",    #'#
 "Privacy,"    . $aid_util'config{'master_path'} . "etc/copyright.html", #'#
);

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

$aid_util'noindex = "  <meta name=\"robots\"  content=\"noindex\">"; #'#
%aid_util'aid_aliases = ();   #'# global alias hash repository 

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
    'sch_id',			# high school (primary or Awalt)
    'year',			# 4-digit grad year or affiliation
    'email',			# email address
    'www',			# personal web page
    'location',			# city, company, or college
    'inethost',			# REMOTE_HOST of last update
    'middle',			# middle initial
    'email_upd',		# date of last update to email
    'email_old',		# previous email address
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
    'sch_id',	'High School',
    'year',	'Graduation Year or Affiliation',
    'email',	'E-mail Address',
    'www',	'Personal Web Page',
    'location',	'Location',
    'inethost',	'',
    'middle',	'Middle Initial',
    'email_upd','',
    'email_old','Previous E-mail Address',
    );

$aid_util'pack_format = 'C3N5'; #'#
$aid_util'pack_len    = 23; #'#

$aid_util'school_default    = 1; #'#
$aid_util'school_awalt      = 2; #'#
$aid_util'school_both       = 3; #'#
@aid_util'school_affil      = ('', '', 'A', 'A/MV');
@aid_util'school_name       = ('', 'MVHS', 'Awalt', 'Awalt/MV');

%aid_util'blank_entry =        #'# a prototypical blank entry to clone
    ();

for ($i = 0; $i <= $#aid_util'field_names; $i++) { #'#
     $aid_util'blank_entry{$aid_util'field_names[$i]} = '';
}

$aid_util'blank_entry{'id'}      = -1;      #'#
$aid_util'blank_entry{'valid'}   = 1;       #'#
$aid_util'blank_entry{'request'} = 4;       #'#
$aid_util'blank_entry{'reunion'} = 1;       #'#
$aid_util'blank_entry{'bounce'} = 0;        #'#
$aid_util'blank_entry{'email_upd'} = 0;     #'#
$aid_util'blank_entry{'email_old'} = '';    #'#
$aid_util'blank_entry{'message'} = '';      #'#
$aid_util'blank_entry{'sch_id'}  = $aid_util'school_default;

%aid_util'image_tag = #'#
    (
    'new',
    "<small><strong class=\"newupd\">*NEW*</strong></small>",

    'new_anchored',
    "<small><strong class=\"newupd\">*NEW*</strong></small>",

    'updated',
    "<small><strong class=\"newupd\">*UPDATED*</strong></small>",

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

sub aid_is_new_html
{
    package aid_util;

    local(*rec) = @_;

    if (&main'is_new($rec{'time'})) #')#
    {
	if (&main'is_new($rec{'created'})) #')#
        {
	    ' ' . $image_tag{'new'};
	}
	else
	{
	    ' ' . $image_tag{'updated'};
	}
    }
    else
    {
	'';
    }
}

sub fullname {
    package aid_util;

    local(*rec) = @_;
    local($mid) = ($rec{'middle'} ne '') ? " $rec{'middle'}." : '';

    if ($rec{'first'} eq '') {
	$rec{'last'};
    } else {
	if ($rec{'married'} ne '') {
	    "$rec{'last'} (now $rec{'married'}), $rec{'first'}${mid}";
	} else {
	    "$rec{'last'}, $rec{'first'}${mid}";
	}
    }
}


sub inorder_fullname {
    package aid_util;

    local(*rec) = @_;
    local($mid) = ($rec{'middle'} ne '') ? "$rec{'middle'}. " : '';

    if ($rec{'first'} eq '') {
	$rec{'last'};
    } else {
	if ($rec{'married'} ne '') {
	    "$rec{'first'} ${mid}$rec{'last'} (now $rec{'married'})";
	} else {
	    "$rec{'first'} ${mid}$rec{'last'}";
	}
    }
}


sub affiliate {
    package aid_util;

    local(*rec,$do_html_p) = @_;
    local($year,$affil,$len,$tmp);

    $affil = '  ';
    $len   = 2;

    if ($rec{'year'} =~ /^\d+$/)
    {
	$affil .= "<a href=\"" . &main'aid_about_path(*rec,1) . "\">" #'#
	    if $do_html_p;
	$year = sprintf("%02d", $rec{'year'} % 100);

	if ($rec{'sch_id'} == $school_default ||
	    $rec{'sch_id'} == $school_awalt ||
	    $rec{'sch_id'} == $school_both)
	{
	    $tmp = $school_affil[$rec{'sch_id'}] . "'" . $year;
	    $affil .= $tmp;
	    $len   += length($tmp);
	}
	else
	{
	    warn "bad school $rec{'sch_id'} (id == $rec{'id'})!\n";
	}

	$affil .= "</a>" if $do_html_p;

    }
    else
    {
	$affil .= "<a href=\"" . &main'aid_about_path(*rec,1) . "\">" #'#
	    if $do_html_p;
	$tmp    = "[" . $school_affil[$rec{'sch_id'}] . " $rec{'year'}]";
	$affil .= $tmp;
	$len   += length($tmp);
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
	warn "aid_join: record is missing key '$field_names[$i]'"
	    unless defined $rec{$field_names[$i]};
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

    $config{'vcard_cgi'} . "/${id}.vcf";
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
    local($body,$instr);
    local($star) = "<font color=\"#$star_fg\">*</font>";
    local(*rec_arg,$blank_entries) = @_;
    local(%rec) = &main'rec_html_entify(*rec_arg); #'#
    local(@school_checked) = ('', '', '', '');
    local(@reqchk,$i,$reunion_chk,@blankies,$prev_email);

    $prev_email = defined $rec{'prev_email'} ? 
	$rec{'prev_email'} : $rec{'email'};
    $rec{'www'} = 'http://' if $rec{'www'} eq '';

    # give defaults if they're being revalidated
    if ($rec{'valid'} == 0)
    {
	$rec{'request'} = $blank_entry{'request'};
	$rec{'reunion'} = $blank_entry{'reunion'};
    }

    for ($i = 0; $i < 5; $i++) {
	$reqchk[$i] = ($rec{'request'} == $i) ? ' checked' : '';
    }
    $reunion_chk = ($rec{'reunion'} == 1) ? ' checked' : '';
    $school_checked[$rec{'sch_id'}] = ' checked';

    $body = '';

    if ($blank_entries ne '')
    {
	if ($blank_entries =~ /email/ &&
	    $rec{'email'} ne '' && $rec{'email'} !~ /\@/)
	{
	    $body .= "<p><strong><span class=\"alert\">Your e-mail\n";
	    $body .= "address appears to be missing a domain name.</span>\n";
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
	    $body .= "<p class=\"alert\"><strong>It appears that\n";
	    $body .= "the following required fields were blank:";
	    $body .= "</strong></p>\n\n<ul>\n";

	    foreach(@blankies)
	    {
		$body .= "<li>" . $field_descr{$_} . "\n";
	    }
	    $body .= "</ul>\n\n";
	}
    }

    $instr = "<p>Please " . (($rec{'id'} != -1) ? "update" : "enter") .
    " the following information about yourself.<br>
Fields marked with a $star
are required.  All other fields are optional.</p>
";

    $body . "
<form method=post action=\"" . $config{'submit_cgi'} . "\"> 

$instr

<table border=0 cellspacing=7>

<tr><td colspan=3 bgcolor=\"#$header_bg\">
<font size=\"+1\"><strong>1. Full Name</strong></font>
</td></tr>
<tr>
  <td valign=top align=right><label
  for=\"first\"><strong>First Name:</strong></label></td>
  <td valign=top>$star</td>
  <td valign=top><input type=text name=\"first\" size=35 
  value=\"$rec{'first'}\" id=\"first\"></td>
</tr>
<tr>
  <td valign=top align=right><label
  for=\"middle\"><strong>Middle Initial:</strong></label></td>
  <td>&nbsp;</td>
  <td valign=top><input type=text name=\"middle\" size=1 maxlength=1
  value=\"$rec{'middle'}\" id=\"middle\"></td>
</tr>
<tr>
  <td valign=top align=right><label 
  for=\"last\"><strong>Last Name/Maiden Name:</strong></label><br>
  <small>(your last name in high school)</small></td>
  <td valign=top>$star</td>
  <td valign=top><input type=text name=\"last\" size=35
  value=\"$rec{'last'}\" id=\"last\"></td>
</tr>
<tr>
  <td valign=top align=right><label
  for=\"married\"><strong>Married Last Name:</strong></label><br>
  <small>(if different from maiden name)</small></td>
  <td>&nbsp;</td>
  <td valign=top><input type=text name=\"married\" size=35
  value=\"$rec{'married'}\" id=\"married\"><br><br></td>
</tr>

<tr><td colspan=3 bgcolor=\"#$header_bg\">
<font size=\"+1\"><strong>2. Graduating Class while at $config{'short_school'}/Awalt</font>
</td></tr>
<tr>
  <td valign=top align=right><strong>High School Attended:</strong></td>
  <td valign=top>$star</td>
  <td valign=top><input type=radio name=\"sch_id\" id=\"school_default\"
  value=\"$school_default\"$school_checked[$school_default]><label
  for=\"school_default\">&nbsp;$school_name[$school_default]</label>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"sch_id\" id=\"school_awalt\"
  value=\"$school_awalt\"$school_checked[$school_awalt]><label
  for=\"school_awalt\">&nbsp;$school_name[$school_awalt]</label>
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=\"sch_id\" id=\"school_both\"
  value=\"$school_both\"$school_checked[$school_both]><label
  for=\"school_both\">&nbsp;Both&nbsp;$school_name[$school_default]&nbsp;&amp;&nbsp;$school_name[$school_awalt]</label>
  <br>
  <small>(Did you attend/graduate from another school such as
  Shoreline or Los Altos HS?  Write about it below in the <strong>What's
  New?</strong> section.)</small></td>
</tr>
<tr>
  <td valign=top align=right><label
  for=\"year\"><strong>Graduation Year or Affiliation:</strong></label><br>
  <small>(such as 1993, 2001, or Teacher)</small></td>
  <td valign=top>$star</td>
  <td valign=top><input type=text name=\"year\" size=35
  value=\"$rec{'year'}\" id=\"year\"><br><br></td>
</tr>

<tr><td colspan=3 bgcolor=\"#$header_bg\">
<font size=\"+1\"><strong>3. Contact Info</strong></font>
</td></tr>
<tr>
  <td valign=top align=right><label
  for=\"email\"><strong>E-mail Address:</strong></label><br>
  <small>(such as chester\@aol.com)</small></td>
  <td valign=top>$star</td>
  <td valign=top><input type=text name=\"email\" size=35
  value=\"$rec{'email'}\" id=\"email\"></td>
</tr>
<tr>
  <td valign=top align=right><label
  for=\"www\"><strong>Personal Web Page:</strong></label></td>
  <td>&nbsp;</td>
  <td valign=top><input type=text name=\"www\" size=35
  value=\"$rec{'www'}\" id=\"www\"></td>
</tr>
<tr>
  <td valign=top align=right><label
  for=\"location\"><strong>Location:</strong></label><br>
  <small>(your city, school, or company)</small></td>
  <td>&nbsp;</td>
  <td valign=top><input type=text name=\"location\" size=35
  value=\"$rec{'location'}\" id=\"location\"><br><br></td>
</tr>

<tr><td colspan=3 bgcolor=\"#$header_bg\">
<font size=\"+1\"><strong>4. What's New?</strong></font>
</td></tr>
<tr>
  <td colspan=3>
  <label for=\"message\">
  Let your classmates know what you've been doing since<br>graduation,
  or any important bits of news you'd like to share.</label><br>
  <textarea name=\"message\" rows=10 cols=55 wrap=hard
  id=\"message\">$rec{'message'}</textarea><br><br>
  </td>
</tr>

<tr><td colspan=3 bgcolor=\"#$header_bg\">
<font size=\"+1\"><strong>5. E-mail Updates</strong></font>
</td></tr>
<tr>
  <td colspan=3><input type=checkbox
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
  $req_descr_long[0]</label>

  <input type=\"hidden\" name=\"id\" value=\"$rec{'id'}\">
  <input type=\"hidden\" name=\"created\" value=\"$rec{'created'}\">
  <input type=\"hidden\" name=\"email_upd\" value=\"$rec{'email_upd'}\">
  <input type=\"hidden\" name=\"prev_email\" value=\"$prev_email\">
  <input type=\"hidden\" name=\"valid\" value=\"1\">
  <br><br>
  </td>
</tr>

<tr><td colspan=3 bgcolor=\"#$header_bg\">
<font size=\"+1\"><strong>6. Continue</strong></font>
</td></tr>

<tr>
<td colspan=3>
Please review the above information and click the
<strong>Next&nbsp;&gt;</strong> button to continue.
<br><input type=\"submit\" value=\"Next&nbsp;&gt;\">
</td>
</tr>

</table>

</form>
";

}


sub sendmail {
    package aid_util;

    local($to,$name,$return_path,$from,$subject,$body) = @_;
    local(*F);
    local($toline,$header);

    $name =~ s/"/'/g;
    $to =~ s/\s*\([^\)]*\)\s*//g;
    $toline = join(', ', split(/[ \t]+/, $to));
    $header =
"From: $from <$return_path>\
To: \"$name\" <$toline>\
X-Sender: $ENV{'USER'}\@$ENV{'HOST'}\
Disposition-Notification-To: $from <$return_path>\ 
Organization: $config{'school'} Alumni Internet Directory\
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

    "\n-- \n" . $config{'admin_name'} . "\n" . $config{'admin_school'};
}

sub aid_verbose_entry {
    package aid_util;

    local(*rec_arg,$display_year,$suppress_new) = @_;
    local($_);
    local($fullname);
    local(*rec);
    local($retval) = '';

    $rec_arg{'message'} = &main'aid_get_usertext($rec_arg{'id'}) #'#
	unless defined($rec_arg{'message'});

    %rec = &main'rec_html_entify(*rec_arg);

    $fullname = &main'inorder_fullname(*rec); #'#

    $retval .= "<dl compact>\n";

    $retval .= "<dt><big>";
    $retval .= "<strong>";
    $retval .= "<a name=\"id-$rec{'id'}\">";
    $retval .=  $fullname;
    $retval .= "</a>";
    $retval .= "</strong>";
    $retval .= "</big>\n";

    $retval .= "&nbsp;<small>[";
    $retval .= "<a href=\"" . &main'aid_vcard_path($rec{'id'}) . "\">"; #'#
    $retval .= "vCard</a>";
    $retval .= "&nbsp;|&nbsp;";
    $retval .= "<a href=\"" . $config{'about_cgi'} . "?about=$rec{'id'}\">";
    $retval .= "update</a>";
    $retval .= "]</small>\n";

    $retval .= &main'aid_is_new_html(*rec) unless $suppress_new; #'#

    $retval .= "</dt>\n";

    if ($rec{'year'} =~ /^\d+$/) {
	# Last Awalt student graduated in 1983
	$retval .= "<dt>School: <strong>$school_name[$rec{'sch_id'}]</strong></dt>\n" 
	    if $rec{'year'} <= 1983;
	if ($display_year) {
	    $retval .= "<dt>Year:  <strong>";
	    $retval .= 
		"<a href=\"" . &main'aid_about_path(*rec,1) . "\">"; #'#
	    $retval .= $rec{'year'};
	    $retval .= "</a></strong></dt>\n";
	}
    } else {
	$retval .= "<dt>School: <strong>$school_name[$rec{'sch_id'}]</strong></dt>\n";
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
    local($v_fn,$v_n,$retval,$message);
    local($mid) = ($rec{'middle'} ne '') ? "$rec{'middle'}. " : '';
    local($v_mid) = ($rec{'middle'} ne '') ? ";$rec{'middle'}" : '';

    # "N:Public;John;Quinlan;Mr.;Esq." ==> "FN:Mr. John Q. Public, Esq."
    if ($rec{'married'} ne '') {
	$v_n  = "N:$rec{'married'};$rec{'first'};$rec{'last'}\015\012";
	$v_fn = "FN:$rec{'first'} ${mid}$rec{'last'} $rec{'married'}\015\012";
    } else {
	$v_n  = "N:$rec{'last'};$rec{'first'}${v_mid}\015\012";
	$v_fn = "FN:$rec{'first'} ${mid}$rec{'last'}\015\012";
    }

    $retval  = "Begin:vCard\015\012";
    $retval .= $v_n;
    $retval .= $v_fn;
    $retval .= "ORG:$school_name[$rec{'sch_id'}];";
    if ($rec{'year'} =~ /^\d+$/) {
	$retval .= "Class of $rec{'year'}\015\012";
    } else {	
	$retval .= "$rec{'year'}\015\012";
    }
    $retval .= "EMAIL;PREF;INTERNET:$rec{'email'}\015\012";
    if ($rec{'location'} =~ /^(.*),\s+(\w\w)$/) {
	$retval .= "ADR:;;;$1;\U$2\E\015\012";
    } else {
	$retval .= "ADR:;;;$rec{'location'}\015\012" if $rec{'location'} ne '';
    }
    $retval .= "URL:$rec{'www'}\015\012" if $rec{'www'} ne '';
    $retval .= "REV:" . &main'aid_vdate($rec{'time'}) . "\015\012"; #'#
    $retval .= "VERSION:2.1\015\012";

#    if ($rec{'message'} !~ /^\s*$/)
#    {
#	$retval .= "NOTE;BASE64:\015\012";
#	$retval .= "  ";
#	$message = &main'old_encode_base64($rec{'message'}, "\015\012  "); #'#;
#	substr($message,-4) = '';
#	$retval .= $message . "\015\012\015\012";
#    }
    $retval .= "End:vCard\015\012";

    $retval;
}


sub about_text {
    package aid_util;

    local($retval) = '';
    local(*rec_arg,$show_req_p,$do_html_p,$do_vcard_p) = @_;
    local(%rec) = $do_html_p ? &main'rec_html_entify(*rec_arg) : %rec_arg; #'#

    $do_vcard_p = 0 unless defined($do_vcard_p);

    $retval .= "<div class=\"about\">\n" if $do_html_p;
    $retval .= "<pre class=\"about\">\n\n" if $do_html_p;

    $retval .= "First Name         : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $rec{'first'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Middle Initial     : ";
    if ($rec{'middle'} ne '')
    {
	$retval .= "<strong>" if $do_html_p;
	$retval .= "$rec{'middle'}.";
	$retval .= "</strong>" if $do_html_p;
    }
    else
    {
	$retval .= "(none)";
    }
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
    $retval .= $school_name[$rec{'sch_id'}];
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
	if $do_html_p && !$show_req_p && $rec{'valid'};
    $retval .= $rec{'email'};
    $retval .= "</a>" if $do_html_p && !$show_req_p && $rec{'valid'};
    $retval .= "</strong>" if $do_html_p;
    if ($rec{'valid'} == 0)
    {
	$retval .= " ";
	$retval .= "<em>" if $do_html_p;
	$retval .= "(invalid address)";
	$retval .= "</em>" if $do_html_p;
    }
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

    if ($do_vcard_p && $do_html_p && $rec{'valid'}) {
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
	$retval .= $do_html_p ? "<blockquote class=\"about\">\n" : "";
	$rec{'message'} =~ s/\n/<br>\n/g if $do_html_p;
	$retval .= $rec{'message'};
	$retval .= $do_html_p ? "</blockquote>\n" : "";
    } else {
	$retval .= "\n";
	$retval .= "What's New?        : (blank)\n";
	$retval .= "</pre>\n" if $do_html_p;
    }

    $retval .= "</div>\n" if $do_html_p;

    $retval;
}

sub common_intro_para {
    package aid_util;

    local($[) = 0;
    local($info) = "The " . $image_tag{'info'} .
	"\nicon lets you get more detailed information about an alumnus.";

    "<p>Any alumni marked with\n" . $image_tag{'new'} . 
    "\nhave been added to the Directory last month.\n" .
    "Alumni marked with\n" . $image_tag{'updated'} . 
	"\nhave updated their information within the past month.\n" .
	($_[0] ? $info : '') .
    "</p>\n" .
    "<p>Were you previously listed but now your name isn't here?  If\n" .
    "e-mail to you has failed to reach you for more than 6 months, your\n" .
    "listing has been moved to the\n" .
    "<a href=\"" . $config{'master_path'} . "invalid.html\">invalid\n" .
    "e-mail addresses</a> page.\n</p>\n\n";
}

sub common_link_table {
    package aid_util;

    local($[) = 0;
    local($page) = @_;
    local($html,$name,$url,$idx);

    $html  = "    <!-- nav begin -->\n";
    $html .= "    <p align=center><small>";

    foreach $idx (0 .. $#page_idx) {
	($name, $url) = split(/,/, $page_idx[$idx]);
        if ($idx == $page) {
	    $html .= "\n      <strong>$name</strong>";
        } else {
            $html .= "<a\n      href=\"$url\">$name</a>";
        }
	$html .= " || " unless $idx == $#page_idx;
    }
    $html .= "\n      <br>";
    foreach $idx (0 .. $#second_idx) {
	($name, $url) = split(/,/, $second_idx[$idx]);
        if ($idx == ($page - 10)) {
	    $html .= "\n      <strong>$name</strong>";
        } else {
            $html .= "<a\n      href=\"$url\">$name</a>";
        }
	$html .= " || " unless $idx == $#second_idx;
    }
    $html .= "\n    </small></p>\n";
    $html .= "    <!-- nav end -->\n";
    
    $html;
}


sub common_html_ftr {
    package aid_util;

    local($[) = 0;
    local($page) = @_;
    local($ftr,$copyright);

    $copyright = $second_idx[6];
    $copyright =~ s/^[^,]+,//;

    $ftr  = "\n<!-- ftr begin -->\n";
    $ftr .= "<hr noshade size=\"1\">\n";
#    $ftr .= &main'common_link_table($page); #'#
    $ftr .= "\n<small>" . $disclaimer . "</small><br>\n\n";

    $ftr .= "\n<br><small><a href=\"" . $copyright . "\">" .
	"Copyright\n&copy; 1999 " . $config{'admin_name'} . "</a></small>\n" .
	"<!-- ftr end -->\n\n</body> </html>\n";

    $ftr;
}


sub common_html_hdr {
    require 'ctime.pl';
    require 'tableheader.pl';
    package aid_util;

    local($page,$title,$norobots,$time) = @_;
    local($hdr,$tablehdr,$timestamp,$titletag);
    local($pagetime) = defined $time ? $time : time;
    local($sec,$min,$hour,@rest) = localtime($pagetime);
    local($ampm) = $hour >= 12 ? 'pm' : 'am';

    $hour -= 12 if $hour > 12;
    $hour  = 12 if $hour == 0;
    $timestamp = sprintf("%s %2d:%02d%s",
			 &main'aid_caldate($pagetime), $hour, $min, $ampm);

    $tablehdr = $title eq '' ? '' :
	"    <!-- \"$title\" --><strong>" .
	&main'tableheader_internal($title,1,$header_fg) . #'#
	    "</strong>\n\n";

    $titletag = ($page == 0) ?
	($config{'school'} . " Alumni Internet Directory") :
	($config{'short_school'} . " Alumni: " . $title);

    $hdr  = 
	"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n" .
	"        \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n" .
	"<html> <head>\n" .
	"  <title>" . $titletag . "</title>\n" . 
	    $pics_label . "\n" . $site_tags . "\n";

    $hdr .= "  <link rel=\"stylesheet\" type=\"text/css\" href=\"http://";
    $hdr .= $config{'master_srv'} . $config{'master_path'};;
    $hdr .= "default.css\">\n";

    $hdr .= "$noindex\n" if $norobots;

    $hdr .= "</head>\n\n";
    
    $hdr .= "<!-- hdr begin -->\n";

    $hdr .= "<body bgcolor=\"#$body_bg\" text=\"#$body_fg\" link=\"#$body_link\" vlink=\"#$body_vlink\">\n";
    
    $hdr .= "
<table cellspacing=0 cellpadding=6 border=0 width=\"100%\" summary=\"\">
  <tr>
    <td bgcolor=\"#$header_bg\" valign=middle>
    <p align=left><a
    href=\"$config{'master_path'}\"><font color=\"#$header_fg\"
    size=\"+2\"><strong><tt>$config{'school'}
    Alumni Internet Directory</tt></strong></font></a></p>
    <p align=right><font color=\"#$header_fg\"><small>
    $timestamp
    </small></font></p>
    </td>
  </tr>
  <tr>
    <td bgcolor=\"#$cell_bg\" align=center valign=middle>
$tablehdr";
    $hdr .= &main'common_link_table($page); #'#
    $hdr .= "    </td>
  </tr>
</table>

<!-- discourage www.roverbot.com -->
<!--BAD-DOG-->

";

    $hdr .= "<!-- hdr end -->\n\n";

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

    $retval .= '</p>' if $do_paragraph;
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
	    "\"Title\",\"First Name\",\"Middle Name\",\"Last Name\",\"Suffix\",\"Company\",\"Department\",\"Job Title\",\"Business Street\",\"Business Street 2\",\"Business Street 3\",\"Business City\",\"Business State\",\"Business Postal Code\",\"Business Country\",\"Home Street\",\"Home Street 2\",\"Home Street 3\",\"Home City\",\"Home State\",\"Home Postal Code\",\"Home Country\",\"Other Street\",\"Other Street 2\",\"Other Street 3\",\"Other City\",\"Other State\",\"Other Postal Code\",\"Other Country\",\"Assistant's Phone\",\"Business Fax\",\"Business Phone\",\"Business Phone 2\",\"Callback\",\"Car Phone\",\"Company Main Phone\",\"Home Fax\",\"Home Phone\",\"Home Phone 2\",\"ISDN\",\"Mobile Phone\",\"Other Fax\",\"Other Phone\",\"Pager\",\"Primary Phone\",\"Radio Phone\",\"TTY/TDD Phone\",\"Telex\",\"Account\",\"Anniversary\",\"Assistant's Name\",\"Billing Information\",\"Birthday\",\"Categories\",\"Children\",\"E-mail Address\",\"E-mail Display Name\",\"E-mail 2 Address\",\"E-mail 2 Display Name\",\"E-mail 3 Address\",\"E-mail 3 Display Name\",\"Gender\",\"Government ID Number\",\"Hobby\",\"Initials\",\"Keywords\",\"Language\",\"Location\",\"Mileage\",\"Notes\",\"Office Location\",\"Organizational ID Number\",\"PO Box\",\"Private\",\"Profession\",\"Referred By\",\"Spouse\",\"User 1\",\"User 2\",\"User 3\",\"User 4\",\"Web Page\"\015\012";
    }
}

sub aid_book_write_entry {
    package aid_util;

    local(*BOOK,$option,*rec) = @_;
    local($long_last) = $rec{'last'};

    $long_last .= " $rec{'married'}" if $rec{'married'} ne '';

    $option eq 'p' && print BOOK "$rec{'alias'}\t$long_last, $rec{'first'}\t$rec{'email'}\t\t$school_name[$rec{'sch_id'}] $rec{'year'}\n";
    $option eq 'e' && print BOOK "$rec{'alias'} = $long_last; $rec{'first'}, $school_name[$rec{'sch_id'}] $rec{'year'} = $rec{'email'}\n";
    $option eq 'b' && print BOOK "alias $rec{'alias'}\t$rec{'email'}\n";
    $option eq 'w' && print BOOK "<$rec{'alias'}>\015\012>$rec{'first'} $long_last <$rec{'email'}>\015\012<$rec{'alias'}>\015\012>$school_name[$rec{'sch_id'}] $rec{'year'}\015\012";
    $option eq 'm' && print BOOK "alias $rec{'alias'} $rec{'email'}\015\012note $rec{'alias'} <name:$rec{'first'} $long_last>$school_name[$rec{'sch_id'}] $rec{'year'}\015\012";

    # netscape is a bigger sucker
    if ($option eq 'n') {
	print BOOK "    <DT><A HREF=\"mailto:$rec{'email'}\" ";
	print BOOK "NICKNAME=\"$rec{'alias'}\">$rec{'first'} $long_last</A>\n";
	print BOOK "<DD>$school_name[$rec{'sch_id'}] $rec{'year'}\n";
    }

    elsif ($option eq 'l') {
        print BOOK "dn: cn=$rec{'first'} $long_last,mail=$rec{'email'}\015\012";
	print BOOK "modifytimestamp: ";
	$vdate = &main'aid_vdate($rec{'time'}); #'#
	$vdate =~ s/T//;
	print BOOK "$vdate\015\012";
        print BOOK "cn: $rec{'first'} $long_last\015\012";
	if ($rec{'married'} ne '') {
	    print BOOK "sn: $rec{'married'}\015\012";
	} else {
	    print BOOK "sn: $rec{'last'}\015\012";
	}
        print BOOK "givenname: $rec{'first'}\015\012";
        print BOOK "objectclass: top\015\012objectclass: person\015\012";
        print BOOK "mail: $rec{'email'}\015\012";
	if ($rec{'location'} =~ /^(.*),\s+(\w\w)$/) {
	    print BOOK "locality: $1\015\012";
	    print BOOK "st: $2\015\012";
	} else {
	    print BOOK "locality: $rec{'location'}\015\012" if $rec{'location'} ne '';
	}
        print BOOK "o: $school_name[$rec{'sch_id'}]\015\012";
	if ($rec{'year'} =~ /^\d+$/) {
	    print BOOK "ou: Class of $rec{'year'}\015\012";
	} else {
	    print BOOK "ou: $rec{'year'}\015\012";
	}
        print BOOK "homeurl: $rec{'www'}\015\012" if $rec{'www'} ne '';
        print BOOK "xmozillanickname: $rec{'alias'}\015\012";
        print BOOK "\015\012";
    }
    
    # lots of data for a vCard
    elsif ($option eq 'v') {
	print BOOK &main'aid_vcard_text(*rec), "\015\012"; #'#
    }

    elsif ($option eq 'o') {
	print BOOK "\"\",\"$rec{'first'}\",";
	if ($rec{'married'} ne '') {
	    print BOOK "\"$rec{'last'}\",\"$rec{'married'}\",";
	} else {
	    print BOOK "\"\",\"$rec{'last'}\",";
	}

	print BOOK "\"\",\"$school_name[$rec{'sch_id'}] $rec{'year'}\",\"\",";
	print BOOK "\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",";

	if ($rec{'location'} =~ /^(.*),\s+(\w\w)$/) {
	    print BOOK "\"$1\",\"$2\",";
	} else {
	    print BOOK "\"$rec{'location'}\",\"\",";
	}

	print BOOK "\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"$config{'short_school'} Alumni\",\"\",\"$rec{'email'}\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"$rec{'www'}\"\015\012";
    }
}

sub aid_book_write_suffix {
    package aid_util;

    local(*BOOK,$option) = @_;

    $option eq 'n' && print BOOK "</DL><p>\n";
}

sub aid_http_date
{
    package aid_util;

    local($time) = @_;
    local(@DoW);
    local($sec,$min,$hour,$mday,$mon,$year,$wday) =
	gmtime($time);

    @DoW = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
    $year += 1900;

    sprintf("%s, %02d %s %4d %02d:%02d:%02d GMT",
	    $DoW[$wday],$mday,$MoY[$mon],$year,$hour,$min,$sec);
}


sub aid_db_pack_rec
{
    package aid_util;

    local(*rec) = @_;

    pack($pack_format,
	 (($rec{'valid'} ? 1 : 0) |
	  (($rec{'reunion'} ? 1 : 0) << 1)),
	 $rec{'request'},
	 $rec{'sch_id'},
	 $rec{'bounce'},
	 $rec{'created'},
	 $rec{'time'},
	 $rec{'fresh'},
	 $rec{'email_upd'}
	 ) .
    join("\0",
	 $rec{'last'},
	 $rec{'married'},
	 $rec{'first'},
	 $rec{'middle'},
	 $rec{'year'},
	 $rec{'email'},
	 $rec{'www'},
	 $rec{'location'},
	 $rec{'inethost'},
	 $rec{'alias'},
	 $rec{'message'},
	 $rec{'email_old'}
	 );
};


sub aid_db_unpack_rec
{
    package aid_util;

    local($key,$val) = @_;
    local(*rec,$masked);

    %rec = ();
    $rec{'id'} = $key;

    (
     $masked,
     $rec{'request'},
     $rec{'sch_id'},
     $rec{'bounce'},
     $rec{'created'},
     $rec{'time'},
     $rec{'fresh'},
     $rec{'email_upd'}
     ) = unpack($pack_format, $val);

    $rec{'valid'}   = ( $masked       & 1) ? 1 : 0;
    $rec{'reunion'} = (($masked >> 1) & 1) ? 1 : 0;

    (
     $rec{'last'},
     $rec{'married'},
     $rec{'first'},
     $rec{'middle'},
     $rec{'year'},
     $rec{'email'},
     $rec{'www'},
     $rec{'location'},
     $rec{'inethost'},
     $rec{'alias'},
     $rec{'message'},
     $rec{'email_old'}
     ) = split(/\0/, substr($val, $pack_len));

    %rec;
};

sub old_encode_base64
{
    package hacked_MIME;

    local($res) = "";
    local($eol) = $_[1];
    $eol = "\n" unless defined $eol;
    while ($_[0] =~ /((.|\n){1,45})/g) {
	$res .= substr(pack('u', $1), 1);
	chop($res);
    }
    $res =~ tr|` -_|AA-Za-z0-9+/|;               # `# help emacs
    # fix padding at the end
    local($padding) = (3 - length($_[0]) % 3) % 3;
    if ($padding)
    {
	$res =~ s/.{$padding}$//;
	$res .= '=' x $padding;
    }
    # break encoded string into lines of no more than 76 characters each
    if (length $eol) {
	$res =~ s/(.{1,76})/$1$eol/g;
    }
    $res;
}

# We get a whole bunch of warnings about "possible typo" when running
# with the -w switch.  Touch them all once to get rid of the warnings.
# This is ugly and I hate it.
if ($^W)
{
    if (0)
    {
	&old_encode_base64();
	&aid_http_date();
	&aid_book_write_suffix();
	&aid_book_write_entry();
	&aid_book_write_prefix();
	&aid_class_jump_bar();
	&aid_build_yearlist();
	&about_text();
	&aid_verbose_entry();
	&aid_html_escape();
	&aid_class_db();
	&aid_alpha_db();
	&aid_parse();
	&aid_join();
	&affiliate();
	&aid_image_tag();
	&common_html_hdr();
	&common_html_ftr();
	&common_intro_para();
	&fullname();
	&is_old();
	&message_footer();
	&sendmail();
	&submit_body();
	&aid_db_unpack_rec();
	&aid_db_pack_rec();
    }
}

1;

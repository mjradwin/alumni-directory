#
#     FILE: aid_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the Alumni Internet Directory
#      $Id: aid_util.pl,v 4.96 1999/05/03 23:32:50 mradwin Exp mradwin $
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

require 'aid_config.pl';
require 'aid_submit.pl';

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
sub aid_is_new
{
    package aid_util;

    local($time,$months) = @_;

    $months = 1 unless $months;
    (((time - $time) < ($months * 2678400)) ? 1 : 0);
}


# is the GMT more than 6 months ago?
# 15724800 = 182 days * 24 hrs * 60 mins * 60 secs
sub aid_is_old
{
    package aid_util;

    local($[) = 0;

    (((time - $_[0]) >= 15724800) ? 1 : 0);
}

sub aid_is_new_html
{
    package aid_util;

    local(*rec) = @_;

    if (&main'aid_is_new($rec{'u'})) #')#
    {
	if (&main'aid_is_new($rec{'c'})) #')#
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

sub aid_fullname
{
    package aid_util;

    local(*rec) = @_;
    local($mi) = ($rec{'mi'} ne '') ? " $rec{'mi'}." : '';

    if ($rec{'gn'} eq '') {
	$rec{'sn'};
    } else {
	if ($rec{'mn'} ne '') {
	    "$rec{'sn'} (now $rec{'mn'}), $rec{'gn'}${mi}";
	} else {
	    "$rec{'sn'}, $rec{'gn'}${mi}";
	}
    }
}


sub aid_inorder_fullname
{
    package aid_util;

    local(*rec) = @_;
    local($mi) = ($rec{'mi'} ne '') ? "$rec{'mi'}. " : '';

    if ($rec{'gn'} eq '') {
	$rec{'sn'};
    } else {
	if ($rec{'mn'} ne '') {
	    "$rec{'gn'} ${mi}$rec{'sn'} (now $rec{'mn'})";
	} else {
	    "$rec{'gn'} ${mi}$rec{'sn'}";
	}
    }
}


sub aid_affiliate
{
    package aid_util;

    local(*rec,$do_html_p) = @_;
    local($year,$affil,$len,$tmp);

    $affil = '  ';
    $len   = 2;

    if ($rec{'yr'} =~ /^\d+$/)
    {
	$affil .= "<a href=\"" . &main'aid_about_path(*rec,1) . "\">" #'#
	    if $do_html_p;
	$year = sprintf("%02d", $rec{'yr'} % 100);

	if ($rec{'s'} == $school_default ||
	    $rec{'s'} == $school_awalt ||
	    $rec{'s'} == $school_both)
	{
	    $tmp = $school_affil[$rec{'s'}] . "'" . $year;
	    $affil .= $tmp;
	    $len   += length($tmp);
	}
	else
	{
	    warn "bad school $rec{'s'} (id == $rec{'id'})!\n";
	}

	$affil .= "</a>" if $do_html_p;

    }
    else
    {
	$affil .= "<a href=\"" . &main'aid_about_path(*rec,1) . "\">" #'#
	    if $do_html_p;
	$tmp    = $school_affil[$rec{'s'}] eq '' ?
	    $school_name[$rec{'s'}] : $school_affil[$rec{'s'}];
	$tmp    = "[$tmp $rec{'yr'}]";
	$affil .= $tmp;
	$len   += length($tmp);
	$affil .= "</a>" if $do_html_p;
    }

    ($affil,$len);
}


# remove punctuation, hyphens, parentheses, and quotes.
sub aid_mangle
{
    package aid_util;

    local($name) = @_;

    $name =~ s/\s//g;
    $name =~ s/\".*\"//g;
    $name =~ s/\(.*\)//g;
    $name =~ s/\'.*\'//g;
    $name =~ s/[^\d\w_-]//g;

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

    if ($rec{'v'} == 0) {
	$rec{'a'} = '';
	return %rec;
    }

    $mangledFirst = &main'aid_mangle($rec{'gn'}); #'#
    if ($rec{'mn'} ne '') {
	$mangledLast = &main'aid_mangle($rec{'mn'});   #'#
    } else {
	$mangledLast = &main'aid_mangle($rec{'sn'});   #'#
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

    $rec{'a'} = $alias;
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

sub aid_vcard_path {
    package aid_util;

    local($id) = @_;

    $config{'vcard_cgi'} . "/${id}.vcf";
}

sub aid_yahoo_abook_path {
    package aid_util;

    local(*rec) = @_;
    local($url) = 'http://address.yahoo.com/yab?A=da&amp;au=a';

    $url .= '&amp;fn=' . &main'aid_url_escape($rec{'gn'});
    if ($rec{'mn'} ne '')
    {
	$url .= '&amp;mn=' . &main'aid_url_escape($rec{'sn'});
	$url .= '&amp;ln=' . &main'aid_url_escape($rec{'mn'});
    }
    else
    {
	$url .= '&amp;mn=' . &main'aid_url_escape($rec{'mi'});
	$url .= '&amp;ln=' . &main'aid_url_escape($rec{'sn'});
    }
    $url .= '&amp;c=Unfiled';
    $url .= '&amp;nn=' . &main'aid_url_escape($rec{'a'});
    $url .= '&amp;e='  . &main'aid_url_escape($rec{'e'});
    $url .= '&amp;pp=0';
    $url .= '&amp;co=' . $school_name[$rec{'s'}];
    if ($rec{'yr'} =~ /^\d+$/) {
	$url .= '+Class+of+' . $rec{'yr'};
    } else {
	$url .= '+' . &main'aid_url_escape($rec{'yr'});
    }

    $url .= '&amp;pu=' . &main'aid_url_escape($rec{'w'});
    $url .= '&amp;af=d';

    if ($rec{'l'} =~ /^(.*),\s+(\w\w)$/)
    {
	$url .= '&amp;hc=' . &main'aid_url_escape($1);
	$url .= '&amp;hs=' . $2;
    }
    elsif ($rec{'l'} =~ /^(.*),\s+(\w\w)\s+(\d\d\d\d\d)$/)
    {
	$url .= '&amp;hc=' . &main'aid_url_escape($1);
	$url .= '&amp;hs=' . $2;
	$url .= '&amp;hz=' . $3;
    }
    else
    {
	$url .= '&amp;hc=' . &main'aid_url_escape($rec{'l'});
    }

    $url .= '&amp;.done=' .
        &main'aid_url_escape('http://' .
			     $config{'master_srv'} . $config{'master_path'});

    $url;
}



sub aid_about_path {
    package aid_util;

    local(*rec,$suppress_anchor_p) = @_;
    local($page) = ($rec{'yr'} =~ /^\d+$/) ? $rec{'yr'} : 'other';
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

sub aid_html_entify_str
{
    package aid_util;

    local($_) = @_;

    s/&/&amp;/g;
    s/</&lt;/g;
    s/>/&gt;/g;
    s/"/&quot;/g; #"#
    s/\s+/ /g;

    $_;
}

sub aid_html_entify_rec
{
    package aid_util;

    local(*rec_arg) = @_;
    local(%rec,$_);

    %rec = %rec_arg;

    foreach (keys %rec) {
	$rec{$_} =~ s/&/&amp;/g;
	$rec{$_} =~ s/</&lt;/g;
	$rec{$_} =~ s/>/&gt;/g;
	$rec{$_} =~ s/"/&quot;/g; #"#
	$rec{$_} =~ s/\s+/ /g unless $_ eq 'n';
    }

    %rec;
}


sub aid_sendmail
{
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


sub aid_verbose_entry {
    package aid_util;

    local(*rec_arg,$display_year,$suppress_new) = @_;
    local($_);
    local($fullname);
    local(*rec);
    local($retval) = '';

    $rec_arg{'n'} = &main'aid_get_usertext($rec_arg{'id'}) #'#
	unless defined($rec_arg{'n'});

    %rec = &main'aid_html_entify_rec(*rec_arg);

    $fullname = &main'aid_inorder_fullname(*rec); #'#

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
    $retval .= "<a target=\"_address\" href=\"" .
	&main'aid_yahoo_abook_path(*rec) . "\">"; #'#
    $retval .= 'add to Y! address book';
    $retval .= "</a>";
    $retval .= "&nbsp;|&nbsp;";
    $retval .= "<a href=\"" . $config{'about_cgi'} . "?about=$rec{'id'}\">";
    $retval .= "update</a>";
    $retval .= "]</small>\n";

    $retval .= &main'aid_is_new_html(*rec) unless $suppress_new; #'#

    $retval .= "</dt>\n";

    if ($rec{'yr'} =~ /^\d+$/) {
	# Last Awalt student graduated in 1983
	$retval .= "<dt>School: <strong>$school_name[$rec{'s'}]</strong></dt>\n" 
	    if $rec{'yr'} <= 1983;
	if ($display_year) {
	    $retval .= "<dt>Year:  <strong>";
	    $retval .= 
		"<a href=\"" . &main'aid_about_path(*rec,1) . "\">"; #'#
	    $retval .= $rec{'yr'};
	    $retval .= "</a></strong></dt>\n";
	}
    } else {
	$retval .= "<dt>School: <strong>$school_name[$rec{'s'}]</strong></dt>\n";
	$retval .= "<dt>Affiliation:  <strong>";
	$retval .= "<a href=\"" . &main'aid_about_path(*rec,1) . "\">"; #'#
	$retval .= $rec{'yr'};
	$retval .= "</a></strong></dt>\n";
    }

    $retval .= "<dt>E-mail: <code><strong><a href=\"mailto:$rec{'e'}\">";
    $retval .= $rec{'e'};
    $retval .= "</a></strong></code></dt>\n";
    $retval .= "<dt>Web Page: <code><strong><a href=\"$rec{'w'}\">$rec{'w'}</a></strong></code></dt>\n"
	if $rec{'w'} ne '';
    $retval .= "<dt>Location: <strong>$rec{'l'}</strong></dt>\n"
	if $rec{'l'} ne '';
    $retval .= "<dt>Updated: ";
    $date = &main'aid_caldate($rec{'u'}); #'#
    $retval .= "<strong>$date</strong></dt>\n";

    if ($rec{'n'} ne '') {
	$retval .= "<dt>What's New?</dt>\n";
	$rec{'n'} =~ s/\n/<br>\n/g;
	$retval .= "<dd>$rec{'n'}</dd>\n";
    }
    $retval .= "</dl>\n\n";

    $retval;
}


sub aid_vcard_text {
    package aid_util;

    local(*rec) = @_;
    local($v_fn,$v_n,$retval);
#    local($message);
    local($mi) = ($rec{'mi'} ne '') ? "$rec{'mi'}. " : '';
    local($v_mi) = ($rec{'mi'} ne '') ? ";$rec{'mi'}" : '';

    # "N:Public;John;Quinlan;Mr.;Esq." ==> "FN:Mr. John Q. Public, Esq."
    if ($rec{'mn'} ne '') {
	$v_n  = "N:$rec{'mn'};$rec{'gn'};$rec{'sn'}\015\012";
	$v_fn = "FN:$rec{'gn'} ${mi}$rec{'sn'} $rec{'mn'}\015\012";
    } else {
	$v_n  = "N:$rec{'sn'};$rec{'gn'}${v_mi}\015\012";
	$v_fn = "FN:$rec{'gn'} ${mi}$rec{'sn'}\015\012";
    }

    $retval  = "Begin:vCard\015\012";
    $retval .= $v_n;
    $retval .= $v_fn;
    $retval .= "ORG:$school_name[$rec{'s'}];";
    if ($rec{'yr'} =~ /^\d+$/) {
	$retval .= "Class of $rec{'yr'}\015\012";
    } else {	
	$retval .= "$rec{'yr'}\015\012";
    }
    $retval .= "EMAIL;PREF;INTERNET:$rec{'e'}\015\012";
    if ($rec{'l'} =~ /^(.*),\s+(\w\w)$/) {
	$retval .= "ADR:;;;$1;\U$2\E\015\012";
    } else {
	$retval .= "ADR:;;;$rec{'l'}\015\012" if $rec{'l'} ne '';
    }
    $retval .= "URL:$rec{'w'}\015\012" if $rec{'w'} ne '';
    $retval .= "REV:" . &main'aid_vdate($rec{'u'}) . "\015\012"; #'#
    $retval .= "VERSION:2.1\015\012";

#    if ($rec{'n'} !~ /^\s*$/)
#    {
#	$retval .= "NOTE;BASE64:\015\012";
#	$retval .= "  ";
#	$message = &main'old_encode_base64($rec{'n'}, "\015\012  "); #'#;
#	substr($message,-4) = '';
#	$retval .= $message . "\015\012\015\012";
#    }
    $retval .= "End:vCard\015\012";

    $retval;
}


sub aid_about_text
{
    package aid_util;

    local($retval) = '';
    local(*rec_arg,$show_req_p,$do_html_p,$do_vcard_p) = @_;
    local(%rec) = $do_html_p ? &main'aid_html_entify_rec(*rec_arg) : %rec_arg; #'#

    $do_vcard_p = 0 unless defined($do_vcard_p);

    $retval .= "<div class=\"about\">\n" if $do_html_p;
    $retval .= "<pre class=\"about\">\n\n" if $do_html_p;

    $retval .= "First Name         : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $rec{'gn'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Middle Initial     : ";
    if ($rec{'mi'} ne '')
    {
	$retval .= "<strong>" if $do_html_p;
	$retval .= "$rec{'mi'}.";
	$retval .= "</strong>" if $do_html_p;
    }
    else
    {
	$retval .= "(none)";
    }
    $retval .= "\n";
    
    $retval .= "Last/Maiden Name   : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $rec{'sn'};
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    $retval .= "Married Last Name  : ";
    if ($rec{'mn'} eq '') {
	$retval .= "(same as last name)";
    } else {
	$retval .= "<strong>" if $do_html_p;
	$retval .= $rec{'mn'};
	$retval .= "</strong>" if $do_html_p;
    }
    $retval .= "\n";
    
    $retval .= "\n";
    $retval .= "School             : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= $school_name[$rec{'s'}];
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";
    
    if ($rec{'yr'} =~ /^\d+$/) {
	$retval .= "Graduation Year    : ";
    } else {
	$retval .= "Affiliation        : ";
    }
    $retval .= "<strong>" if $do_html_p;
    $retval .= "<a href=\"" . &main'aid_about_path(*rec) . "\">" #'#
	    if $do_html_p && !$show_req_p;
    $retval .= $rec{'yr'};
    $retval .= "</a>" if $do_html_p && !$show_req_p;
    $retval .= "</strong>" if $do_html_p;
    $retval .= "\n";

    $retval .= "\n";
    $retval .= "E-mail             : ";
    $retval .= "<strong>" if $do_html_p;
    $retval .= "<a href=\"mailto:$rec{'e'}\">"
	if $do_html_p && !$show_req_p && $rec{'v'};
    $retval .= $rec{'e'};
    $retval .= "</a>" if $do_html_p && !$show_req_p && $rec{'v'};
    $retval .= "</strong>" if $do_html_p;
    if ($rec{'v'} == 0)
    {
	$retval .= " ";
	$retval .= "<em>" if $do_html_p;
	$retval .= "(invalid address)";
	$retval .= "</em>" if $do_html_p;
    }
    $retval .= "\n";

    $retval .= "Personal Web Page  : ";
    $retval .= ($rec{'w'} eq '') ? "(none)\n" :
	((($do_html_p) ? "<strong><a href=\"$rec{'w'}\">" : "") .
	 $rec{'w'} . 
	 (($do_html_p) ? "</a></strong>" : "") .
	 "\n");

    $retval .= "Location           : ";
    $retval .= ($rec{'l'} eq '') ? "(none)\n" :
	((($do_html_p) ? "<strong>" : "") .
	 $rec{'l'} .
	 (($do_html_p) ? "</strong>" : "") .
	 "\n");

    if ($do_vcard_p && $do_html_p && $rec{'v'}) {
	$retval .= "vCard              : ";
	$retval .= "<a href=\"" . &main'aid_vcard_path($rec{'id'}) . "\">"; #'#
	$retval .= $image_tag{'vcard'};
	$retval .= "</a>\n";

	$retval .= "Yahoo! Address Book: ";
	$retval .= "<a target=\"_address\" href=\"" .
	    &main'aid_yahoo_abook_path(*rec) . "\">"; #'#
	$retval .= 'Add to My Personal Address Book';
	$retval .= "</a>\n";
    }

    if ($show_req_p) {
	$retval .= "\n";
	$retval .= "Reunion Info Okay  : ";
	$retval .= ($rec{'r'} == 1) ?
	    "yes\n" : "no\n";
	$retval .= "Send E-mail Digests: ";
	$retval .= defined $req_descr[$rec{'q'}] ?
	    "$req_descr[$rec{'q'}]\n" : "(unknown)\n";
    } 

    if ($rec{'u'} ne '' && $rec{'u'} != 0 &&
	$rec{'c'} ne '' && $rec{'c'} != 0) {
	$retval .= "\n";
	$retval .= "Last Updated       : ";
	$retval .= &main'aid_caldate($rec{'u'}) . "\n"; #'#
	$retval .= "Joined Directory   : ";
        $retval .= &main'aid_caldate($rec{'c'}) . "\n"; #'#
    }

    $rec{'n'} = &main'aid_get_usertext($rec{'id'}) #'#
	unless defined($rec{'n'});

    if ($rec{'n'} ne '') {
	$retval .= "\n";
	$retval .= "What's New?        :\n";
	$retval .= "</pre>\n" if $do_html_p;
	$retval .= $do_html_p ? "<blockquote class=\"about\">\n" : "";
	$rec{'n'} =~ s/\n/<br>\n/g if $do_html_p;
	$retval .= $rec{'n'};
	$retval .= $do_html_p ? "</blockquote>\n" : "";
    } else {
	$retval .= "\n";
	$retval .= "What's New?        : (blank)\n";
	$retval .= "</pre>\n" if $do_html_p;
    }

    $retval .= "</div>\n" if $do_html_p;

    $retval;
}

sub aid_common_intro_para
{
    package aid_util;

    local($[) = 0;
    local($info) = "The <tt>" . $image_tag{'info'} .
	"</tt>\nicon lets you get more detailed information about an alumnus.";

    "<p>Any alumni marked with\n<small>" . $image_tag{'new'} . 
    "</small>\nhave been added to the Directory last month.\n" .
    "Alumni marked with\n<small>" . $image_tag{'updated'} . 
	"</small>\nhave updated their information within the past month.\n" .
	($_[0] ? $info : '') .
    "</p>\n" .
    "<p>Were you previously listed but now your name isn't here?  If\n" .
    "e-mail to you has failed to reach you for more than 6 months, your\n" .
    "listing has been moved to the\n" .
    "<a href=\"" . $config{'master_path'} . "invalid.html\">invalid\n" .
    "e-mail addresses</a> page.\n</p>\n\n";
}

sub aid_common_link_table
{
    package aid_util;

    local($[) = 0;
    local($page) = @_;
    local($html,$name,$url,$idx);

    $html  = "    <!-- nav begin -->\n";
    $html .= "    <p align=\"center\"><small>";

    foreach $idx (0 .. $#page_idx) {
	($name, $url) = split(/,/, $page_idx[$idx]);
        if ($idx == $page) {
	    $html .= "\n      <strong>$name</strong>";
        } else {
            $html .= "<a\n      href=\"$url\">$name</a>";
        }
	$html .= ' - ' unless $idx == $#page_idx;
    }
    $html .= "\n      <br />";
    foreach $idx (0 .. $#second_idx) {
	($name, $url) = split(/,/, $second_idx[$idx]);
        if ($idx == ($page - 10)) {
	    $html .= "\n      <strong>$name</strong>";
        } else {
            $html .= "<a\n      href=\"$url\">$name</a>";
        }
	$html .= ' - ' unless $idx == $#second_idx;
    }
    $html .= "\n    </small></p>\n";
    $html .= "    <!-- nav end -->\n";
    
    $html;
}


sub aid_common_html_ftr
{
    package aid_util;

    local($[) = 0;
    local($page) = @_;
    local($ftr);
    local($year) = (localtime(time))[5] + 1900;

    $ftr  = "\n<!-- ftr begin -->\n";
    $ftr .= "<hr noshade size=\"1\">\n";

    $ftr .= "\n<div class=\"about\">\n";
    $ftr .= &main'aid_common_link_table($page); #'#
    $ftr .="</div>\n";

    $ftr .= "\n<small>\n" . $disclaimer . "\n<br><br>\n";

    $ftr .= "<a href=\"" . $copyright_path . "\">" .
	"Copyright\n&copy; $year " . $config{'admin_name'} . "</a>\n</small>\n" .
	"<!-- ftr end -->\n\n</body> </html>\n";

    $ftr;
}


sub aid_common_html_hdr
{
    require 'ctime.pl';
    require 'tableheader.pl';
    package aid_util;

    local($page,$title,$norobots,$time,$subtitle) = @_;
    local($hdr,$tablehdr,$timestamp,$titletag);
    local($pagetime) = defined $time ? $time : time;
    local($sec,$min,$hour) = localtime($pagetime);
    local($ampm) = $hour >= 12 ? 'pm' : 'am';

    $hour -= 12 if $hour > 12;
    $hour  = 12 if $hour == 0;
    $timestamp = sprintf("%s %2d:%02d%s",
			 &main'aid_caldate($pagetime), $hour, $min, $ampm);

    $tablehdr = $title eq '' ? '' :
	"    <!-- \"$title\" --><strong>" .
	&main'tableheader_internal($title,1,$header_fg) . #'#
	    "</strong>\n";
    $tablehdr .= "    <br>$subtitle\n" if defined $subtitle && $subtitle ne '';
    $tablehdr .= "\n";

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
<table cellspacing=\"0\" cellpadding=\"6\" border=\"0\" width=\"100%\">
  <tr>
    <td bgcolor=\"#$header_bg\" valign=\"middle\">
    <p align=\"left\"><a
    href=\"$config{'master_path'}\"><font color=\"#$header_fg\"
    size=\"+2\"><strong><tt>$config{'school'}
    Alumni Internet Directory</tt></strong></font></a></p>
    <p align=\"right\"><font color=\"#$header_fg\"><small>
    $timestamp
    </small></font></p>
    </td>
  </tr>
  <tr>
    <td bgcolor=\"#$cell_bg\" align=\"center\" valign=\"middle\">
$tablehdr";
    $hdr .= &main'aid_common_link_table($page); #'#
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
	    $retval .= "[ <a name=\"top\"";
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

    $retval .= ' ]';
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
    local($long_last) = $rec{'sn'};
    local($mi) = $rec{'mi'} ne '' ? "$rec{'mi'}." : '';
    local($mi_spc) = $rec{'mi'} ne '' ? " $rec{'mi'}." : '';

    $long_last .= " $rec{'mn'}" if $rec{'mn'} ne '';

    $option eq 'p' && print BOOK "$rec{'a'}\t$long_last, $rec{'gn'}$mi_spc\t$rec{'e'}\t\t$school_name[$rec{'s'}] $rec{'yr'}\n";
    $option eq 'e' && print BOOK "$rec{'a'} = $long_last; $rec{'gn'}, $school_name[$rec{'s'}] $rec{'yr'} = $rec{'e'}\n";
    $option eq 'b' && print BOOK "alias $rec{'a'}\t$rec{'e'}\n";
    $option eq 'w' && print BOOK "<$rec{'a'}>\015\012>$rec{'gn'}$mi_spc $long_last <$rec{'e'}>\015\012<$rec{'a'}>\015\012>$school_name[$rec{'s'}] $rec{'yr'}\015\012";
    $option eq 'm' && print BOOK "alias $rec{'a'} $rec{'e'}\015\012note $rec{'a'} <name:$rec{'gn'}$mi_spc $long_last>$school_name[$rec{'s'}] $rec{'yr'}\015\012";

    # netscape is a bigger sucker
    if ($option eq 'n') {
	print BOOK "    <DT><A HREF=\"mailto:$rec{'e'}\" ";
	print BOOK "NICKNAME=\"$rec{'a'}\">$rec{'gn'}$mi_spc $long_last</A>\n";
	print BOOK "<DD>$school_name[$rec{'s'}] $rec{'yr'}\n";
    }

    elsif ($option eq 'l') {
        print BOOK "dn: cn=$rec{'gn'}$mi_spc $long_last,mail=$rec{'e'}\015\012";
	print BOOK "modifytimestamp: ";
	$vdate = &main'aid_vdate($rec{'u'}); #'#
	$vdate =~ s/T//;
	print BOOK "$vdate\015\012";
        print BOOK "cn: $rec{'gn'}$mi_spc $long_last\015\012";
	if ($rec{'mn'} ne '') {
	    print BOOK "sn: $rec{'mn'}\015\012";
	} else {
	    print BOOK "sn: $rec{'sn'}\015\012";
	}
        print BOOK "givenname: $rec{'gn'}\015\012";
        print BOOK "objectclass: top\015\012objectclass: person\015\012";
        print BOOK "mail: $rec{'e'}\015\012";
	if ($rec{'l'} =~ /^(.*),\s+(\w\w)$/) {
	    print BOOK "locality: $1\015\012";
	    print BOOK "st: $2\015\012";
	} else {
	    print BOOK "locality: $rec{'l'}\015\012" if $rec{'l'} ne '';
	}
        print BOOK "o: $school_name[$rec{'s'}]\015\012";
	if ($rec{'yr'} =~ /^\d+$/) {
	    print BOOK "ou: Class of $rec{'yr'}\015\012";
	} else {
	    print BOOK "ou: $rec{'yr'}\015\012";
	}
        print BOOK "homeurl: $rec{'w'}\015\012" if $rec{'w'} ne '';
        print BOOK "xmozillanickname: $rec{'a'}\015\012";
        print BOOK "\015\012";
    }
    
    # lots of data for a vCard
    elsif ($option eq 'v') {
	print BOOK &main'aid_vcard_text(*rec), "\015\012"; #'#
    }

    elsif ($option eq 'o') {
	print BOOK "\"\",\"$rec{'gn'}\",";
	if ($rec{'mn'} ne '') {
	    print BOOK "\"$rec{'sn'}\",\"$rec{'mn'}\",";
	} else {
	    print BOOK "\"$mi\",\"$rec{'sn'}\",";
	}

	print BOOK "\"\",\"$school_name[$rec{'s'}] $rec{'yr'}\",\"\",";
	print BOOK "\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",";

	if ($rec{'l'} =~ /^(.*),\s+(\w\w)$/) {
	    print BOOK "\"$1\",\"$2\",";
	} else {
	    print BOOK "\"$rec{'l'}\",\"\",";
	}

	print BOOK "\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"$config{'short_school'} Alumni\",\"\",\"$rec{'e'}\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"$rec{'w'}\"\015\012";
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
	 (($rec{'v'} ? 1 : 0) |
	  (($rec{'r'} ? 1 : 0) << 1)),
	 $rec{'q'},
	 $rec{'s'},
	 $rec{'b'},
	 $rec{'c'},
	 $rec{'u'},
	 $rec{'f'},
	 $rec{'eu'}
	 ) .
    join("\0",
	 $rec{'sn'},
	 $rec{'mn'},
	 $rec{'gn'},
	 $rec{'mi'},
	 $rec{'yr'},
	 $rec{'e'},
	 $rec{'w'},
	 $rec{'l'},
	 $rec{'h'},
	 $rec{'a'},
	 $rec{'n'},
	 $rec{'eo'}
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
     $rec{'q'},
     $rec{'s'},
     $rec{'b'},
     $rec{'c'},
     $rec{'u'},
     $rec{'f'},
     $rec{'eu'}
     ) = unpack($pack_format, $val);

    $rec{'v'} = ( $masked       & 1) ? 1 : 0;
    $rec{'r'} = (($masked >> 1) & 1) ? 1 : 0;

    (
     $rec{'sn'},
     $rec{'mn'},
     $rec{'gn'},
     $rec{'mi'},
     $rec{'yr'},
     $rec{'e'},
     $rec{'w'},
     $rec{'l'},
     $rec{'h'},
     $rec{'a'},
     $rec{'n'},
     $rec{'eo'}
     ) = split(/\0/, substr($val, $pack_len));

    %rec;
}

sub aid_rebuild_secondary_keys
{
    package aid_util;

    local(*DB,$quiet,$debug) = @_;
    local(%old_db,%new_db);
    local($key,$val,$id);
    local(@diffs) = ();

    local($latest) = 0;
    local($latest_www) = 0;
    local($latest_awalt) = 0;
    local($latest_goner) = 0;
    local(%awalt) = ();
    local(%class_members) = ();
    local(%class_latest) = ();
    local(%www_class_members) = ();
    local(@datakeys) = ();
    local(@alpha_ids) = ();
    local(%alpha_members) = ();
    local(%alpha_latest) = ();
    local($maxval) = -1;

    # first pass -- gather all names with alpha data
    print STDERR "$0: building index..." unless $quiet;
    while(($key,$val) = each(%DB))
    {
	if ($key =~ /^\d+$/)
	{
	    %rec = &main'aid_db_unpack_rec($key,$val); #'#;
	    push(@datakeys,
		 "\L$rec{'sn'}\0$rec{'gn'}\0$rec{'mi'}\0$rec{'mn'}\0$rec{'yr'}\E\0" . $key);
	    $maxval = $key if $key > $maxval;
	}
	elsif ($key =~ /^_/)
	{
	    $old_db{$key} = $val;
	}
    }
    print STDERR "." unless $quiet;
    
    # can't delete while iterating, so do it now
    while(($key,$val) = each(%old_db))
    {
	delete $DB{$key};
    }

    # now sort by alpha
    foreach (sort { $a cmp $b } @datakeys)
    {
	$id = (split(/\0/))[5];
	die "split failed: id $id invalid: $_" unless $id =~ /^\d+$/;
	push(@alpha_ids,$id);
    }
    undef(@datakeys);		# garbage-collect
    print STDERR "." unless $quiet;

    # second pass - timestamps and lists
    foreach $id (@alpha_ids)
    {
	%rec = &main'aid_db_unpack_rec($id,$DB{$id}); #'#;

	if ($rec{'v'})
	{
	    $latest = $rec{'u'} if $rec{'u'} > $latest;

	    $ln_key = substr($rec{'sn'},0,1);
	    $ln_key = "\L$ln_key\E";
	    if (defined $alpha_members{$ln_key})
	    {
		$alpha_members{$ln_key} .= ' ' . $rec{'id'};
		$alpha_latest{$ln_key}   = $rec{'u'} if
		    $rec{'u'} > $alpha_latest{$ln_key};
	    }
	    else
	    {
		$alpha_members{$ln_key}  =       $rec{'id'};
		$alpha_latest{$ln_key}   =       $rec{'u'};
	    }

	    $ykey = ($rec{'yr'} =~ /^\d+$/) ? $rec{'yr'} : 'other';
	    if (defined $class_members{$ykey})
	    {
		$class_members{$ykey} .= ' ' . $rec{'id'};
		$class_latest{$ykey}   =       $rec{'u'} if
		    $rec{'u'} > $class_latest{$ykey};
	    }
	    else
	    {
		$class_members{$ykey}  =       $rec{'id'};
		$class_latest{$ykey}   =       $rec{'u'};
	    }

	    if ($rec{'w'} ne '')
	    {
		$latest_www = $rec{'u'} if $rec{'u'} > $latest_www;
		if (defined $www_class_members{$ykey})
		{
		    $www_class_members{$ykey} .= ' ' . $rec{'id'};
		}
		else
		{
		    $www_class_members{$ykey}  =       $rec{'id'};
		}
	    }

	    if ($rec{'s'} == $aid_util'school_awalt ||
		$rec{'s'} == $aid_util'school_both)
	    {
		$latest_awalt = $rec{'u'} if $rec{'u'} > $latest_awalt;

		if (defined $awalt{$ykey})
		{
		    $awalt{$ykey} .= ' ' . $rec{'id'};
		}
		else
		{
		    $awalt{$ykey}  =       $rec{'id'};
		}
	    }
	}
	else
	{
	    $latest_goner = $rec{'b'} if $rec{'b'} > $latest_goner;
	    $latest_goner = $rec{'f'} if $rec{'f'} > $latest_goner;
	}

    }
    print STDERR "." unless $quiet;

    $DB{'_alpha'} = pack("n*", @alpha_ids);

    @class_ids = ();
    @years = sort keys %class_members;
    $DB{'_years'} = pack("n*",grep(/\d+/,@years));

    foreach $ykey (@years)
    {
	@alpha_ids = split(/ /, $class_members{$ykey});
	$DB{"_${ykey}"} = pack("n*", @alpha_ids);
	$DB{"_t_${ykey}"} = pack("N", $class_latest{$ykey});
	$new_db{"_${ykey}"} = $new_db{"_t_${ykey}"} = 1;
	push(@class_ids, @alpha_ids);
    }
    print STDERR "." unless $quiet;

    $DB{'_class'} = pack("n*", @class_ids);

    # now do years, but only for www
    @years = sort keys %www_class_members;
    $DB{'_www_years'} = pack("n*",grep(/\d+/,@years));
    foreach $ykey (@years)
    {
	$DB{"_www_${ykey}"} = pack("n*", split(/ /, $www_class_members{$ykey}));
	$new_db{"_www_${ykey}"} = 1;
    }
    print STDERR "." unless $quiet;

    # now do years, but only for awalt
    @years = sort keys %awalt;
    $DB{'_awalt_years'} = pack("n*",grep(/\d+/,@years));
    foreach $ykey (@years)
    {
	$DB{"_awalt_${ykey}"} = pack("n*", split(/ /, $awalt{$ykey}));
	$new_db{"_awalt_${ykey}"} = 1;
    }
    print STDERR "." unless $quiet;

    $DB{'_t'} = pack("N", $latest);
    $DB{'_t_www'} = pack("N", $latest_www);
    $DB{'_t_awalt'} = pack("N", $latest_awalt);
    $DB{'_t_goner'} = pack("N", $latest_goner);
    $DB{'_nextid'}  = $maxval + 1;

    while (($key,$val) = each(%alpha_members))
    {
	$DB{"_a_${key}"} = pack("n*", split(/ /, $val));
	$new_db{"_a_${key}"} = 1;
    }

    while (($key,$val) = each(%alpha_latest))
    {
	$DB{"_t_${key}"} = pack("N", $val);
	$new_db{"_t_${key}"} = 1;
    }
    print STDERR ".\n" unless $quiet;

    # static keys (always present)
    $new_db{'_alpha'} =  $new_db{'_years'} =
	$new_db{'_class'} = $new_db{'_www_years'} = $new_db{'_awalt_years'} =
	    $new_db{'_t'} = $new_db{'_t_www'} = $new_db{'_t_awalt'} =
		$new_db{'_t_goner'} = $new_db{'_nextid'} = 1;

    while (($key,$val) = each(%DB))
    {
	next unless $key =~ /^_/;
	die "invariant failed: key=$key in DB but not in new_db\n"
	    unless defined $new_db{$key};

	if (! defined $old_db{$key})
	{
	    warn "$key: new\n" if $debug;
	    push(@diffs,$key);
	}
	elsif ($val ne $old_db{$key})
	{
	    warn "$key: changed\n" if $debug;
	    push(@diffs,$key);
	}
    }

    while (($key,$val) = each(%old_db))
    {
	if (! defined $new_db{$key})
	{
	    warn "$key: del\n" if $debug;
	    push(@diffs,$key);
	}
    }

    @diffs;
}

sub aid_url_escape
{
    package aid_util;

    local($_) = @_;
    local($res) = '';

    foreach (split(//))
    {
	if (/ /)
	{
	    $res .= '+';
	}
	elsif (/[^a-zA-Z0-9_.-]/)
	{
	    $res .= sprintf("%%%02X", ord($_));
	}
	else
	{
	    $res .= $_;
	}
    }

    $res;
}

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
if ($^W && 0)
{
    &old_encode_base64();
    &aid_http_date();
    &aid_book_write_suffix();
    &aid_book_write_entry();
    &aid_book_write_prefix();
    &aid_class_jump_bar();
    &aid_build_yearlist();
    &aid_about_text();
    &aid_verbose_entry();
    &aid_html_entify_str();
    &aid_create_db();
    &aid_parse();
    &aid_join();
    &aid_affiliate();
    &aid_common_html_hdr();
    &aid_common_html_ftr();
    &aid_common_intro_para();
    &aid_fullname();
    &aid_is_old();
    &aid_sendmail();
    &aid_db_unpack_rec();
    &aid_db_pack_rec();
    &aid_yahoo_abook_path();
    &aid_url_escape();

    $aid_util'ID_INDEX = '';
    $aid_util'body_vlink = '';
    $aid_util'school_both = '';
    $aid_util'body_bg = '';
    $aid_util'body_fg = '';
    $aid_util'pack_len = '';
    $aid_util'cell_bg = '';
    $aid_util'school_default = '';
    $aid_util'MoY = '';
    $aid_util'noindex = '';
    $aid_util'disclaimer = '';
    $aid_util'school_awalt = '';
    $aid_util'pics_label = '';
    $aid_util'site_tags = '';
    $aid_util'header_bg = '';
    $aid_util'body_link = '';
    &aid_rebuild_secondary_keys();
}

1;

#
#     FILE: aid_util.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the Alumni Internet Directory
#      $Id: aid_util.pl,v 5.107 2003/02/20 01:20:54 mradwin Exp mradwin $
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

require 'school_config.pl';
require 'aid_config.pl';
require 'aid_submit.pl';

use lib "/pub/m/r/mradwin/private/lib/perl5/site_perl";

use MIME::QuotedPrint;
use Net::SMTP; 
use Time::Local;
use POSIX qw(strftime);

sub aid_caldate
{
    package aid_util;

    my($time) = @_;

    &POSIX::strftime("%e-%b-%Y", localtime($time));
}

sub aid_vdate {
    package aid_util;

    my($time) = @_;

    my($sec,$min,$hour,$day,$month,$year) = gmtime($time);
    sprintf("%d%02d%02dT%02d%02d%02dZ", $year+1900, $month+1, $day,
	    $hour, $min, $sec);
}

# is the GMT less than one month ago?
# 2678400 = 31 days * 24 hrs * 60 mins * 60 secs
sub aid_is_new
{
    package aid_util;

    my($time,$months) = @_;

    $months = 1 unless $months;
    (((time - $time) < ($months * 2678400)) ? 1 : 0);
}


# is the GMT more than 6 months ago?
# 15724800 = 182 days * 24 hrs * 60 mins * 60 secs
sub aid_is_old
{
    package aid_util;

    my($time) = @_;

    (((time - $time) >= 15724800) ? 1 : 0);
}

sub aid_is_new_html
{
    package aid_util;

    local(*rec) = @_;

    if (&main::aid_is_new($rec{'u'}))
    {
	if (&main::aid_is_new($rec{'c'}))
        {
	    "\n&nbsp;" . $image_tag{'new'};
	}
	else
	{
	    "\n&nbsp;" . $image_tag{'updated'};
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
    my($mi) = ($rec{'mi'} ne '') ? " $rec{'mi'}." : '';

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


sub aid_protect_email {
    package aid_util;
    my($e) = @_;

    my($u,$d) = split(/\@/, $e, 2);
    "$u@" . substr($d, 0, 1) . "...";
}

sub aid_inorder_fullname
{
    package aid_util;

    local(*rec) = @_;
    my($mi) = ($rec{'mi'} ne '') ? "$rec{'mi'}. " : '';

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
    my($year,$affil,$len,$tmp);

    $affil = '  ';
    $len   = 2;

    if ($rec{'yr'} =~ /^\d+$/)
    {
	$affil .= "<a href=\"" .
	    &main::aid_about_path(*rec,1) . "\">" 
	    if $do_html_p;
	$year = sprintf("%02d", $rec{'yr'} % 100);

	$tmp = "'" . $year;
	$affil .= $tmp;
	$len   += length($tmp);

	$affil .= "</a>" if $do_html_p;

    }
    else
    {
	$affil .= "<a href=\"" .
	    &main::aid_about_path(*rec,1) . "\">" 
	    if $do_html_p;
	$tmp    = '[' . $config{'short_school'} . ' ' . $rec{'yr'} . ']';
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

    my($name) = @_;

    $name =~ s/\s+//g;
#    $name =~ s/\".*\"//g;
#    $name =~ s/\(.*\)//g;
#    $name =~ s/\'.*\'//g;
    $name =~ s/[^\d\w-]//g;

    $name;
}


sub aid_ampersand_join
{
    package aid_util;

    local(*rec) = @_;
    my($key,$val,$retval);
    local($_);

    $retval = 'id=' . &main::aid_url_escape($rec{'id'}); 

    foreach (@main::aid_edit_field_names)
    {
	next if $_ eq 'id';
	$retval .= '&' . $_   . '=' . &main::aid_url_escape($rec{$_}); 
    }
    
    $retval . '&n=' . &main::aid_url_escape($rec{'n'}); 
}

sub aid_generate_alias
{
    package aid_util;

    local(*rec) = @_;

    my($a7,$alias);
    if (defined $rec{'a'} && $rec{'a'} ne '') {
	$alias = lc($rec{'a'});
	$a7 = substr($alias, 0, 7);
    } else {
	my($mangledLast,$mangledFirst);

	$mangledFirst = &main::aid_mangle($rec{'gn'}); 
	if ($rec{'mn'} ne '') {
	    $mangledLast = &main::aid_mangle($rec{'mn'});   
	} else {
	    $mangledLast = &main::aid_mangle($rec{'sn'});   
	}

	$alias = lc(substr($mangledFirst, 0, 1) . $mangledLast);
	$a7 = substr($alias, 0, 7);
    }

    if (defined($aid_aliases{$a7})) {
	$aid_aliases{$a7}++;
	$alias = $a7 . $aid_aliases{$a7};
    } else {
	$aid_aliases{$a7} = 1;
    }

    $alias;
}

sub aid_vcard_path {
    package aid_util;

    local(*rec) = @_;

    $config{'vcard_cgi'} . '/' . $rec{'id'} . '/' . 
	&main::aid_mangle($rec{'gn'}) . &main::aid_mangle($rec{'sn'}) . 
	    &main::aid_mangle($rec{'mn'}) . '.vcf';
}

sub aid_yahoo_abook_path {
    package aid_util;

    local(*rec) = @_;
    my($url) = 'http://address.yahoo.com/yab?A=da&amp;au=a';

    $url .= '&amp;fn=' . &main::aid_url_escape($rec{'gn'}); 
    if ($rec{'mn'} ne '')
    {
	$url .= '&amp;mn=' . &main::aid_url_escape($rec{'sn'}); 
	$url .= '&amp;ln=' . &main::aid_url_escape($rec{'mn'}); 
    }
    else
    {
	$url .= '&amp;mn=' . &main::aid_url_escape($rec{'mi'}); 
	$url .= '&amp;ln=' . &main::aid_url_escape($rec{'sn'}); 
    }
    $url .= '&amp;c=Unfiled';
    $url .= '&amp;nn=' . &main::aid_url_escape($rec{'a'}); 
    $url .= '&amp;e='  . &main::aid_url_escape($rec{'e'}); 
    $url .= '&amp;pp=0';
    $url .= '&amp;co=' . $config{'short_school'};
    if ($rec{'yr'} =~ /^\d+$/) {
	$url .= '+Class+of+' . $rec{'yr'};
    } else {
	$url .= '+' . &main::aid_url_escape($rec{'yr'}); 
    }

    $url .= '&amp;pu=' . &main::aid_url_escape($rec{'w'}); 
    $url .= '&amp;af=d';

    if ($rec{'l'} =~ /^(.*),\s+(\w\w)$/)
    {
	$url .= '&amp;hc=' . &main::aid_url_escape($1); 
	$url .= '&amp;hs=' . $2;
    }
    elsif ($rec{'l'} =~ /^(.*),\s+(\w\w)\s+(\d\d\d\d\d)$/)
    {
	$url .= '&amp;hc=' . &main::aid_url_escape($1); 
	$url .= '&amp;hs=' . $2;
	$url .= '&amp;hz=' . $3;
    }
    else
    {
	$url .= '&amp;hc=' . &main::aid_url_escape($rec{'l'}); 
    }

    $url .= '&amp;.done=' .
	&main::aid_url_escape('http://' . $config{'master_srv'} . 
	    $config{'master_path'});

    $url;
}



sub aid_about_path {
    package aid_util;

    local(*rec,$suppress_anchor_p) = @_;
    my($page) = ($rec{'yr'} =~ /^\d+$/) ? $rec{'yr'} : 'other';
    my($anchor) = ($suppress_anchor_p) ? '' : "#id-$rec{'id'}";

    "$config{'master_path'}class/${page}.html${anchor}";
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
    local($_);
    my(%rec);

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

sub aid_verification_message {
    package aid_util;

    local($randkey,*rec) = @_;

    my($name) = $rec{'gn'};
    $name .= " $rec{'mi'}."
	if defined $rec{'mi'} && $rec{'mi'} ne '';
    $name .= " $rec{'sn'}";
    $name .= " $rec{'mn'}"
	if defined $rec{'mn'} && $rec{'mn'} ne '';
    $name =~ s/\"/\'/g;

    my($return_path,$from,$subject,$xtrahead,$body,$recip);

    $body = &main::aid_inorder_fullname(*rec) . ",

You recently were asked to verify your e-mail address
with the " . $config{'short_school'} . " Alumni Internet Directory.

Please follow the instructions below to complete the
verification process.

TO VERIFY YOUR ADDRESS:

1. If your email reader will allow you to click on
links, click the following link.  If not, enter the URL
into your browser:

http://" . $config{'master_srv'} . $config{'verify_cgi'} . "?$randkey

2. If the page asks you to enter your 8-letter
verification code, please enter this code:

$randkey

3. Then click on the \"Submit verification code\" button.


WAS THIS EMAIL SENT TO THE WRONG ADDRESS?

If you did not request this confirmation, you can
remove your e-mail address from our database by
clicking on the following link:

http://" . $config{'master_srv'} . $config{'remove_cgi'} . "?$randkey

If this link does not work for you, please reply to
this message with the word REMOVE in the subject line
(and be sure to include the full text of this email in
your reply).

Regards,

" . $config{'short_school'} . " Alumni Internet Directory
http://" . $config{'master_srv'} . $config{'master_path'} . "\n";

    $return_path = $config{'devnull_email'};
    $from = $config{'short_school'} . ' Alumni Robot';
    $subject = $config{'short_school'} .
	" Alumni Internet Directory Verification [$randkey]";
    $xtrahead = "Reply-To: " . $config{'admin_email'};

    ($return_path,$from,$subject,$xtrahead,$body,$name,$rec{'e'});
}


sub aid_sendmail
{
    package aid_util;

    my($return_path,$from,$subject,$body,@recip) = @_;

    &main::aid_sendmail_v2($return_path,$from,$subject,'',$body,@recip);
}

sub aid_sendmail_v2
{
    package aid_util;

    my($return_path,$from,$subject,$xtrahead,$body,@recip) = @_;
    my($message,$i,$to,$cc,@targets);

    my($smtp) = Net::SMTP->new($config{'smtp_svr'}, Timeout => 30);
    unless ($smtp) {
	return 0;
    }

    chomp($xtrahead);
    $xtrahead .= "\n" if $xtrahead ne '';

    $to = "\"$recip[0]\" <$recip[1]>";
    @targets = ($recip[1]);
    shift(@recip);
    shift(@recip);
    $cc = '';
    for ($i = 0; $i < @recip; $i += 2)
    {
	$cc .= ', ' unless $cc eq '';
	$cc .= "\"$recip[$i]\" <$recip[$i+1]>";
	push(@targets, $recip[$i+1]);
    }
    $cc = "Cc: $cc\n" if $cc ne '';

    $message =
"From: $from <$return_path>
To: $to
${cc}Organization: $config{'school'} Alumni Internet Directory
${xtrahead}MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Subject: $subject
";

#    my($login) = getlogin() || getpwuid($<) || "UNKNOWN";
#    my($hostname) = $ENV{'HOST'} || `/bin/hostname`;
#    $message .= "X-Sender: $login\@$hostname\n";

    $message .= "\n" . &main::encode_qp($body);

    unless ($smtp->mail($return_path)) {
	warn "smtp mail() failure for @targets\n";
        return 0;
    }
    foreach (@targets) {
	unless($smtp->to($_)) {
	    warn "smtp to() failure for $_\n";
            return 0;
        }
    }
    unless($smtp->data()) {
	warn "smtp data() failure for @targets\n";
        return 0;
    }
    unless($smtp->datasend($message)) {
	warn "smtp datasend() failure for @targets\n";
        return 0;
    }
    unless($smtp->dataend()) {
	warn "smtp dataend() failure for @targets\n";
        return 0;
    }
    unless($smtp->quit) {
	warn "smtp quit failure for @targets\n";
        return 0;
    }

    1;
}


sub aid_verbose_entry {
    package aid_util;

    local(*rec_arg,$display_year,$suppress_new,$suppress_links) = @_;
    local($_);
    my($fullname);
    my($retval) = '';

    local(%rec) = &main::aid_html_entify_rec(*rec_arg);

    $fullname = &main::aid_inorder_fullname(*rec); 

    $retval .= "<dl>\n";

    $retval .= "<dt><big>";
    $retval .= "<b>";
    $retval .= "<a name=\"id-$rec{'id'}\">";
    $retval .=  $fullname;
    $retval .= "</a>";
    $retval .= "</b>";
    $retval .= "</big>";
    $retval .= &main::aid_is_new_html(*rec) unless $suppress_new; 
#    $retval .= "</dt>";
    $retval .= "\n";

    if (! $suppress_links && $rec{'v'})
    {
	$retval .= "<dt>Tools: <small>" .
	    "<a\nhref=\"" .
	    &main::aid_vcard_path(*rec_arg) . "\">" . 
	    "vCard</a> | " .
	    "<a\nhref=\"" . $config{'about_cgi'} .
	    "/$rec{'id'}\">modify</a> | <a\n" .
	    "href=\"" .  $config{'yab_cgi'} . "/$rec{'id'}\">" .
	    "add to Y! address book</a></small>";
#	$retval .= "</dt>";
	$retval .= "\n";

    }

    if ($rec{'yr'} =~ /^\d+$/) {
	if ($display_year) {
	    $retval .= "<dt>Year: <b><a\n" .
		"href=\"" . &main::aid_about_path(*rec,1) . "\">" . 
		    $rec{'yr'} . "</a></b>";
#	$retval .= "</dt>";
	$retval .= "\n";

	}
    } else {
	$retval .= "<dt>Affiliation: <b><a\n" .
	    "href=\"" . &main::aid_about_path(*rec,1) . "\">" . 
		$rec{'yr'} . "</a></b>";
#	$retval .= "</dt>";
	$retval .= "\n";

    }

    $retval .= "<dt>E-mail: <tt><b>";
    $retval .= ("<a\nhref=\"" . $config{'message_cgi'} . 
		"?to=" . $rec{'id'} . "\">")
	if $rec{'v'};
    $retval .= &main::aid_protect_email($rec{'e'});
    $retval .= "</a>" if $rec{'v'};
    $retval .= "\n<em>(invalid address)</em>" unless $rec{'v'};
    $retval .= "</b></tt>";
#    $retval .= "</dt>";
    $retval .= "\n";

    $retval .= "<dt>Web Page: <tt><b><a\n" . 
	"href=\"$rec{'w'}\">$rec{'w'}</a></b></tt>\n"
	    if $rec{'w'} ne '';
    $retval .= "<dt>Location: <b>$rec{'l'}</b>\n"
	if $rec{'l'} ne '';
    $retval .= "<dt>Updated: ";
    $date = &main::aid_caldate($rec{'u'}); 
    $retval .= "<b>$date</b>";
#    $retval .= "</dt>";
    $retval .= "\n";

    if ($rec{'n'} ne '') {
	$retval .= "<dt>What's New?\n";
	$rec{'n'} =~ s/[ ]*\n/<br>\n/g;
	$retval .= "<dd>$rec{'n'}</dd>\n";
    }
    $retval .= "</dl>\n\n";

    $retval;
}


sub aid_vcard_text {
    package aid_util;

    local(*rec) = @_;
    my($v_fn,$v_n,$retval);
    my($mi) = ($rec{'mi'} ne '') ? "$rec{'mi'}. " : '';
    my($v_mi) = ($rec{'mi'} ne '') ? ";$rec{'mi'}" : '';

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
    $retval .= "ORG:" . $config{'short_school'} . ";";
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
    $retval .= "REV:" . &main::aid_vdate($rec{'u'}) . "\015\012"; 
    $retval .= "VERSION:2.1\015\012";

#    if ($rec{'n'} !~ /^\s*$/)
#    {
#	$retval .= "NOTE;BASE64:\015\012";
#	$retval .= "  ";
#	$message = &main::encode_base64($rec{'n'}, "\015\012  ");
#	substr($message,-4) = '';
#	$retval .= $message . "\015\012\015\012";
#    }
    $retval .= "End:vCard\015\012";

    $retval;
}


sub aid_about_text
{
    package aid_util;

    local(*rec) = @_;

    my($retval) = '';
    $retval .= &main::aid_inorder_fullname(*rec) . "\n";

    if ($rec{'yr'} =~ /^\d+$/) {
	$retval .= $config{'short_school'} . " Class of " . $rec{'yr'} . "\n";
    } else {
	$retval .= "Affiliation: " . $rec{'yr'} . "\n\n";
    }

    $retval .= "E-mail: " . $rec{'e'} . "\n";

    if ($rec{'w'} ne '' || $rec{'l'} ne '') {
	$retval .= "Web Page: " . $rec{'w'} . "\n"
	    if $rec{'w'} ne '';
	$retval .= "Location: " . $rec{'l'} . "\n"
	    if $rec{'l'} ne '';
	$retval .= "\n";
    }

    if ($rec{'n'} ne '') {
	$retval .= "What's New?\n-----------\n" . $rec{'n'} . 
	    "\nLast Updated: " . &main::aid_caldate($rec{'u'}) . "\n";
    } else {
	$retval .= "Last Updated: " . &main::aid_caldate($rec{'u'}) . "\n"; 
    }

    $retval .= "\nPreferences\n-----------\n";
    $retval .= "My class officers may send me reunion info via e-mail:\n";
    $retval .= ($rec{'r'} == 1) ? " --> yes\n" : " --> no\n";
    $retval .= "Receive a digest of the Directory every quarter:\n";
    $retval .= defined $req_descr[$rec{'q'}] ?
	" --> $req_descr[$rec{'q'}]\n" : " --> no\n";

    $retval;
}

sub aid_common_intro_para
{
    package aid_util;

    my($page) = @_;
    my($info) = "The <tt>" . $image_tag{'info'} .
	"</tt>\nicon lets you get more detailed information about an alumnus.";

    "<p><small>Any alumni marked with\n" . $image_tag{'new'} . 
    "\nhave been added to the Directory last month.\n" .
    "Alumni marked with\n" . $image_tag{'updated'} . 
    "\nhave updated their information within the past month.\n" .
    ($page ? $info : '') .
    "</small></p>\n" .
    "<small>Were you previously listed but now your name isn't here?  If\n" .
    "e-mail to you has failed to reach you for more than 6 months, your\n" .
    "listing has been moved to the\n" .
    "<a href=\"" . $config{'master_path'} . "invalid.html\">invalid\n" .
    "e-mail addresses</a> page.\n</small>\n\n";
}

sub aid_common_html_ftr
{
    require 'ctime.pl';

    package aid_util;

    my($page,$time) = @_;
    my($ftr);
    my($year) = (localtime(time))[5] + 1900;

    $time = time unless (defined $time && $time =~ /\d+/ && $time ne '0');

    $ftr  = "\n<hr noshade=\"noshade\" size=\"1\">\n";

    $ftr .= "<small>\n<!-- hhmts start -->\nLast modified: ";
    $ftr .= &main::ctime($time); 
    $ftr .= "<!-- hhmts end -->\n<br>\n";
    $ftr .= "<a href=\"" . $copyright_path . "\">" .
	"Copyright</a>\n&copy; $year " . $config{'admin_name'} . 
	".  All rights reserved.\n" .
	"<br><br>\n";
    $ftr .= $disclaimer . "\n" .
	"<a\nhref=\"" . $config{'master_path'} .
	"etc/privacy.html\">More info on privacy</a>." .
	"</small>\n</body>\n</html>\n";

    $ftr;
}


sub aid_common_html_hdr
{
    package aid_util;

    my($page,$title,$norobots,$time,$subtitle,$extra_meta) = @_;
    my($hdr,$titletag,$srv_nowww,$descr);
    my($timestamp) =
	&main::aid_caldate((defined $time && $time ne '') ? $time : time); 

    $title = &main::aid_html_entify_str($title);
    $subtitle = &main::aid_html_entify_str($subtitle)
	if defined $subtitle;

    $titletag = ($page == 0) ?
	($config{'school'} . " Alumni Internet Directory") :
	($config{'short_school'} . " Alumni: " . $title);

    $hdr  = 
	"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n" .
	"\t\"http://www.w3.org/TR/html4/loose.dtd\">\n" .
#		"<html xmlns=\"http://www.w3.org/TR/xhtml1\">\n" .
	"<html lang=\"en\">\n" .
	"<head>\n<title>" . $titletag . "</title>\n";

    # do stylesheet before the rest of the meta tags on the theory that
    # early evaluation is good
    $hdr .= "<link rel=\"stylesheet\" type=\"text/css\" href=\"http://";
    $hdr .= $config{'master_srv'} . $config{'master_path'};
    $hdr .= "default.css\">\n";

    # Rich Site Summary
    $hdr .= "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"RSS\" href=\"http://";
    $hdr .= $config{'master_srv'} . $config{'master_path'};
    $hdr .= "summary.rdf\">\n";

    $hdr .= $pics_label . "\n" . $author_meta . "\n" . $navigation_meta . "\n";

    if (! $norobots)
    {
	$descr = $descr_meta;
	$descr =~ s/__DATE__/$timestamp/g;
	$hdr .= $descr;
    }

    $hdr .= $extra_meta if defined $extra_meta;
    $hdr .= "\n<base target=\"_top\"></head>\n";
    
    $hdr .= "<body>\n";

    $srv_nowww =  $config{'master_srv'};
    $srv_nowww =~ s/^www\.//i;

    $hdr .=
	"<form method=\"get\" action=\"$config{'search_cgi'}\">
<table width=\"100%\" class=\"navbar\">
<tr><td><small>\n<b><a href=\"/\">$srv_nowww</a></b> <tt>-&gt;</tt>\n";
    $hdr .= "<a href=\"$config{'master_path'}\">" unless $page == 0;
    $hdr .= $config{'short_school'} . ' Alumni';
    if ($page == 0)
    {
	$hdr .= "\n";
    }
    else
    {
	$hdr .= "</a>" unless $page == 0;
	if (defined $parent_page_name{$page})
	{
	    $hdr .= " <tt>-&gt;</tt>\n" .
		'<a href="' . $parent_page_path{$page} . '">' .
		    $parent_page_name{$page} . '</a>';
	}

	$hdr .= " <tt>-&gt;</tt>\n$title\n";
    }

    $hdr .= qq{</small></td><td align="right"><input
type="text" name="q" size="20">
<input type="submit" value="Search"></td></tr></table></form>
};

    if ($page == 0)
    {
	$hdr .= "<h1>$config{'school'}\n";
	$hdr .= "Alumni Internet Directory</h1>";
    }
    else
    {
	$hdr .= "<p class=\"overline\"><b>$config{'short_school'}\n";
	$hdr .= "Alumni Internet Directory:</b></p>\n";
	$hdr .= "<h1>$title";
	$hdr .= "\n- <small>$subtitle</small>"
	    if defined $subtitle && $subtitle ne '';
	$hdr .= "</h1>";
    }

    $hdr .= "\n<!--BAD-DOG-->\n";

    $hdr;
}

sub aid_build_yearlist {
    package aid_util;

    local($[) = 0;
    local(*years,$year) = @_;

    if (!defined @years)
    {
	@years = ();
	push(@years, ($year =~ /^\d+$/) ? $year : 'other');
    }
    elsif ($years[$#years] ne $year && $years[$#years] ne 'other')
    {
	push(@years, ($year =~ /^\d+$/) ? $year : 'other');
    }

    1;
}

sub aid_class_jump_bar {
    package aid_util;

    local($href_begin,$href_end,*years,$do_paragraph,$hilite) = @_;
    my($retval) = $do_paragraph ? '<p>' : '';
    my($i);

    if (defined @years && defined $years[0])
    {
	$retval .= "[ <a name=\"top\"";
	if (defined $hilite && $years[0] eq $hilite)
	{
	    $retval .= ">";
	}
	else
	{
	    $retval .= " href=\"${href_begin}$years[0]${href_end}\">";
	}
	$retval .= ($years[0] eq 'other') ? "Faculty/Staff" :
	    sprintf("%02d", $years[0] % 100);
	$retval .= "</a>";

	foreach $i (1 .. $#years)
	{
	    $retval .= " |\n";
	    $retval .= "<a href=\"${href_begin}$years[$i]${href_end}\">"
		unless defined $hilite && $years[$i] eq $hilite;
	    $retval .= ($years[$i] eq 'other') ? "Faculty/Staff" :
		sprintf("%02d", $years[$i] % 100);
	    $retval .= "</a>"
		unless defined $hilite && $years[$i] eq $hilite;
	}

	$retval .= ' ]';
	$retval .= '</p>' if $do_paragraph;
	$retval .= "\n\n";
    }

    $retval;
}



sub aid_book_write_prefix {
    package aid_util;

    local(*BOOK,$option) = @_;
    my($school) = $config{'school'};

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
    my($long_last) = $rec{'sn'};
    my($mi) = $rec{'mi'} ne '' ? "$rec{'mi'}." : '';
    my($mi_spc) = $rec{'mi'} ne '' ? " $rec{'mi'}." : '';

    $long_last .= " $rec{'mn'}" if $rec{'mn'} ne '';
    $long_last =~ s/\"/\'/g;
    $long_last =~ s/[,;\t]/ /g;

    my($gn) = $rec{'gn'};
    $gn =~ s/\"/\'/g;
    $gn =~ s/[,;\t]/ /g;

    $option eq 'p' && print BOOK "$rec{'a'}\t$long_last, $gn$mi_spc\t$rec{'e'}\t\t$config{'short_school'} $rec{'yr'}\n";
    $option eq 'e' && print BOOK "$rec{'a'} = $long_last; $gn, $config{'short_school'} $rec{'yr'} = $rec{'e'}\n";
    $option eq 'b' && print BOOK "alias $rec{'a'}\t$rec{'e'}\n";
    $option eq 'w' && print BOOK "<$rec{'a'}>\015\012>$gn$mi_spc $long_last <$rec{'e'}>\015\012<$rec{'a'}>\015\012>$config{'short_school'} $rec{'yr'}\015\012";
    $option eq 'm' && print BOOK "alias $rec{'a'} $rec{'e'}\015\012note $rec{'a'} <name:$gn$mi_spc $long_last>$config{'short_school'} $rec{'yr'}\015\012";

    # netscape is a bigger sucker
    if ($option eq 'n') {
	print BOOK "    <DT><A HREF=\"mailto:$rec{'e'}\" ";
	print BOOK "NICKNAME=\"$rec{'a'}\">$gn$mi_spc $long_last</A>\n";
	print BOOK "<DD>$config{'short_school'} $rec{'yr'}\n";
    }

    elsif ($option eq 'l') {
        print BOOK "dn: cn=$gn$mi_spc $long_last,mail=$rec{'e'}\015\012";
	print BOOK "modifytimestamp: ";
	$vdate = &main::aid_vdate($rec{'u'}); 
	$vdate =~ s/T//;
	print BOOK "$vdate\015\012";
        print BOOK "cn: $gn$mi_spc $long_last\015\012";
	if ($rec{'mn'} ne '') {
	    print BOOK "sn: $rec{'mn'}\015\012";
	} else {
	    print BOOK "sn: $rec{'sn'}\015\012";
	}
        print BOOK "givenname: $gn\015\012";
        print BOOK "objectclass: top\015\012objectclass: person\015\012";
        print BOOK "mail: $rec{'e'}\015\012";
	if ($rec{'l'} =~ /^(.*),\s+(\w\w)$/) {
	    print BOOK "locality: $1\015\012";
	    print BOOK "st: $2\015\012";
	} else {
	    print BOOK "locality: $rec{'l'}\015\012" if $rec{'l'} ne '';
	}
        print BOOK "o: $config{'short_school'}\015\012";
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
	print BOOK &main::aid_vcard_text(*rec), "\015\012"; 
    }

    elsif ($option eq 'o') {
	%rec_copy = %rec;
	$rec_copy{'gn'} =~ s/"/'/g;
	$rec_copy{'sn'} =~ s/"/'/g;
	$rec_copy{'mn'} =~ s/"/'/g;
	$mi =~ s/"/'/g;

	print BOOK "\"\",\"$rec_copy{'gn'}\",";
	if ($rec_copy{'mn'} ne '') {
	    print BOOK "\"$rec_copy{'sn'}\",\"$rec_copy{'mn'}\",";
	} else {
	    print BOOK "\"$mi\",\"$rec_copy{'sn'}\",";
	}

	print BOOK "\"\",\"$config{'short_school'} $rec{'yr'}\",\"\",";
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

    my($time) = @_;
	
    &POSIX::strftime("%a, %d %b %Y %H:%M:%S GMT", gmtime($time));
}


sub aid_db_pack_rec
{
    package aid_util;

    local(*rec) = @_;

    pack($pack_format,
	 (($rec{'v'} ? 1 : 0) |
	  (($rec{'r'} ? 1 : 0) << 1)),
	 $rec{'q'},
	 0,
	 $rec{'b'},
	 $rec{'c'},
	 $rec{'u'},
	 $rec{'f'},
	 $rec{'eu'},
	 $rec{'lm'}
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
	 $rec{'eo'},
	 $rec{'iu'}
	 );
};


sub aid_db_unpack_rec
{
    package aid_util;

    my($key,$val) = @_;
    my($masked,$ignored);

    my(%rec) = ();
    $rec{'id'} = $key;

    (
     $masked,
     $rec{'q'},
     $ignored,
     $rec{'b'},
     $rec{'c'},
     $rec{'u'},
     $rec{'f'},
     $rec{'eu'},
     $rec{'lm'}
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
     $rec{'eo'},
     $rec{'iu'}
     ) = split(/\0/, substr($val, $pack_len));

    %rec;
}

sub aid_rebuild_secondary_keys
{
    package aid_util;

    local(*DB,$quiet,$debug,$preserve_nextid) = @_;
    my(%old_db,%new_db);
    my($key,$val,$id);
    my(@diffs) = ();

    my($latest) = 0;
    my($latest_www) = 0;
    my($latest_goner) = 0;
    my(%class_members) = ();
    my(%class_latest) = ();
    my(%www_class_members) = ();
    my(@datakeys) = ();
    my(@alpha_ids) = ();
    my(%alpha_members) = ();
    my(%alpha_latest) = ();
    my($maxval) = -1;
    my($old_nextid) = $DB{'_nextid'};

    # first pass -- gather all names with alpha data
    select(STDOUT); $| = 1;
    print STDOUT "$0: building index..." unless $quiet;
    while(($key,$val) = each(%DB))
    {
	if ($key =~ /^\d+$/)
	{
	    %rec = &main::aid_db_unpack_rec($key,$val);
	    push(@datakeys,
		 "\L$rec{'sn'}\0$rec{'gn'}\0$rec{'mi'}\0$rec{'mn'}\0$rec{'yr'}\E\0" . $key);
	    $maxval = $key if $key > $maxval;
	}
	elsif ($key =~ /^_/)
	{
	    $old_db{$key} = $val;
	}
    }
    print STDOUT "." unless $quiet;
    
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
    print STDOUT "." unless $quiet;

    # second pass - timestamps and lists
    foreach $id (@alpha_ids)
    {
	%rec = &main::aid_db_unpack_rec($id,$DB{$id});

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
	}
	else
	{
	    $latest_goner = $rec{'b'} if $rec{'b'} > $latest_goner;
	    $latest_goner = $rec{'f'} if $rec{'f'} > $latest_goner;
	}

    }
    print STDOUT "." unless $quiet;

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
    print STDOUT "." unless $quiet;

    $DB{'_class'} = pack("n*", @class_ids);

    # now do years, but only for www
    @years = sort keys %www_class_members;
    $DB{'_www_years'} = pack("n*",grep(/\d+/,@years));
    foreach $ykey (@years)
    {
	$DB{"_www_${ykey}"} = pack("n*", split(/ /, $www_class_members{$ykey}));
	$new_db{"_www_${ykey}"} = 1;
    }
    print STDOUT "." unless $quiet;

    $DB{'_t'} = pack("N", $latest);
    $DB{'_t_www'} = pack("N", $latest_www);
    $DB{'_t_goner'} = pack("N", $latest_goner);
    $DB{'_nextid'}  = $preserve_nextid ? $old_nextid: $maxval + 1;

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
    print STDOUT ".\n" unless $quiet;

    # static keys (always present)
    $new_db{'_alpha'} =  $new_db{'_years'} =
	$new_db{'_class'} = $new_db{'_www_years'} =
	    $new_db{'_t'} = $new_db{'_t_www'} =
		$new_db{'_t_goner'} = $new_db{'_nextid'} = 1;

    while (($key,$val) = each(%DB))
    {
	next unless $key =~ /^_/;
	die "invariant failed: key=$key in DB but not in new_db"
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

sub aid_url_unescape
{
    package aid_util;

    local($_) = @_;

    # Convert plus to space
    s/\+/ /g;

    # Convert %XX from hex numbers to alphanumeric
    s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;

    $_;
}


sub aid_url_escape
{
    package aid_util;

    local($_) = @_;

    s/([^\w\$. -])/sprintf("%%%02X", ord($1))/eg;
    s/ /+/g;

    $_;
}

sub aid_cgi_die
{
    package aid_util;

    my($title,$html) = @_;

    print "Content-Type: text/html\015\012\015\012";

    print &main::aid_common_html_hdr(-1,$title,1);
    print "<p>", $html, "<p>\n" if (defined $html && $html !~ /^\s*$/);
    print &main::aid_common_html_ftr(-1);

    close(STDOUT);
    exit(0);
}


sub aid_write_reunion_hash
{
    package aid_util;

    local(*FH,$entries) = @_;
    my($key);
    my($first) = 1;

    foreach $key (sort keys %{$entries})
    {
	my($date,$html) = split(/\0/, $entries->{$key}, 2);
	my($year,$mon,$mday) = split(/\//, $date, 3);
	my($t) = &Time::Local::timelocal(59,59,23,$mday,$mon-1,$year-1900);

	if ($first)
	{
	    $first = 0;
	    print FH "<dl>\n<dt><b>";
	}
	else
	{
	    print FH "<dt><br><b>";
	}

	print FH &main::aid_config('school');

	if ($key =~ /^\d+$/)
	{
	    print FH " <a name=\"r$key\"\nhref=\"", 
	    &main::aid_config('master_path'),
	    "class/$key.html\">Class of $key</a>";
	}
	else
	{
	    my($clean_key) = lc($key);
	    $clean_key =~ s/[^\w]/_/g;
	    $clean_key =~ s/_+/_/g;
	    $clean_key =~ s/^_//;
	    $clean_key =~ s/_$//;

	    print FH " - <a name=\"$clean_key\">$key</a>";
	}

	print FH "</b></dt>\n",
	"<dd>Date: ", &POSIX::strftime("%A, %B %e, %Y", localtime($t)),
	"</dd>\n",
	$html, "\n";

	# y! calendar
	if ($t > time)
	{
	    print FH "<dd><a\n",
	    "href=\"http://calendar.yahoo.com/?v=60&amp;TITLE=",
	    &main::aid_url_escape(&main::aid_config('school'));

	    print FH &main::aid_url_escape(" Class of")
		if ($key =~ /^\d+$/);
	    print FH &main::aid_url_escape(" $key Reunion");
	    printf FH "&amp;ST=%4d%02d%02d", $year, $mon, $mday;
	    print FH "&amp;VIEW=d\" target=\"_calendar\">Add\n",
	    "This Event To My Personal Yahoo! Calendar</a></dd>\n";
	}
    }

    print FH "</dl>\n\n" unless $first;
    1;
}

sub aid_die_if_failure
{
    package aid_util;

    my($exit_value) = $? >> 8;
    my($signal_num) = $? & 127;
    die "\nKilled with signal $signal_num\n" if $signal_num;
    die "Exited with $exit_value\n" if $exit_value;

    1;
}

# We get a whole bunch of warnings about "possible typo" when running
# with the -w switch.  Touch them all once to get rid of the warnings.
# This is ugly and I hate it.
if ($^W && 0)
{
    &aid_http_date();
    &aid_book_write_suffix();
    &aid_book_write_entry();
    &aid_book_write_prefix();
    &aid_class_jump_bar();
    &aid_build_yearlist();
    &aid_about_text();
    &aid_verbose_entry();
    &aid_html_entify_str();
    &aid_ampersand_join();
    &aid_affiliate();
    &aid_common_html_hdr();
    &aid_common_html_ftr();
    &aid_common_intro_para();
    &aid_fullname();
    &aid_is_old();
    &aid_sendmail_v2();
    &aid_sendmail();
    &aid_db_unpack_rec();
    &aid_db_pack_rec();
    &aid_yahoo_abook_path();
    &aid_url_escape();
    &aid_rebuild_secondary_keys();
    &aid_generate_alias();

    $aid_util::pack_len = '';
    $aid_util::disclaimer = $aid_util::copyright_path = '';
    $aid_util::pics_label = '';
    $aid_util::author_meta = $aid_util::navigation_meta = $aid_util::descr_meta;
    %aid_util::parent_page_path = ();

    @aid_edit_field_names = ();
}

1;

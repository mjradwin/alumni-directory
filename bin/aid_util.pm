#
#     FILE: aid_util.pm
#   AUTHOR: Michael J. Radwin
#    DESCR: perl library routines for the Alumni Directory
#      $Id: aid_util.pm,v 7.35 2013/09/11 04:08:53 mradwin Exp $
#
# Copyright (c) 2007  Michael J. Radwin.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
#  * Redistributions of source code must retain the above
#    copyright notice, this list of conditions and the following
#    disclaimer.
#
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials
#    provided with the distribution.
#
#  * Neither the name of the High School Alumni Directory
#    nor the names of its contributors may be used to endorse or
#    promote products derived from this software without specific
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

BEGIN {
  if ($0 =~ m,(.*[/\\]),) {
    unshift @INC, $1;
  } else {
    unshift @INC, '.';
  }
}

use lib "/home/mradwin/local/share/perl";
use lib "/home/mradwin/local/share/perl/site_perl";

use strict;
use DBI ();
use MIME::QuotedPrint;
use Net::SMTP::SSL ();
use Time::Local;
use POSIX qw(strftime);
use Date::Calc ();

require 'school_config.pl';

package aid_util;

my($VERSION) = '$Revision: 7.35 $$';
if ($VERSION =~ /(\d+)\.(\d+)/) {
    $VERSION = "$1.$2";
}

my $HOSTNAME;

die "NO CONFIG DEFINED!!" unless defined %aid_util::config;

%aid_util::parent_page_name =
(
  '1' => 'Alphabetically',
  '2' => 'Graduating Classes',
 '20' => 'Join or Modify Your Profile',
 '26' => 'Search',
);

%aid_util::parent_page_path =
(
  '1' => $aid_util::config{'master_path'} . 'alpha/',
  '2' => $aid_util::config{'master_path'} . 'class/',
 '20' => $aid_util::config{'master_path'} . 'add/'  ,
 '26' => $aid_util::config{'search_cgi'}            ,
);

$aid_util::pics_label =
"<meta http-equiv=\"PICS-Label\" content='(PICS-1.1 " . 
"\"http://www.rsac.org/ratingsv01.html\" l gen true " . 
"on \"1998.03.10T11:49-0800\" r (n 0 s 0 v 0 l 0))'>"; #"#

%aid_util::aid_aliases = ();   # global alias hash repository 

%aid_util::field_descr =
    (
    'id' =>	'[numerical userid]',
    'v' =>	'[valid bit describing status]',
    'sn' =>	'Last Name/Maiden Name',
    'mn' =>	'Married Last Name',
    'gn' =>	'First Name',
    'r' =>	'[bit for reunion email request]',
    'b' =>	'[unix time - first bounce (0 if none)]',
    'c' =>	'[unix time - record creation]',
    'u' =>	'[unix time - last update]',
    'f' =>	'[unix time - last successful verification]',
    'yr' =>	'Graduation Year or Affiliation',
    'e' =>	'E-mail Address',
    'w' =>	'Personal Web Page',
    'l' =>	'Location',
    'h' =>	'[REMOTE_HOST of last update]',
    'mi' =>	'Middle Initial',
    'eu' =>	'[unix time - last update to email]',
    'eo' =>	'Previous E-mail Address',
    'a' =>	'[alias (a.k.a. nickname)]',
    'n' =>	'What\'s New? note',
    'lm' =>	'[unix time - last time mailing was sent]',
    'iu' =>	'Image URL',
    );

@aid_util::edit_field_names = # in the order we'd like to edit them
    (
     'id',
     'sn', 'gn', 'mi', 'mn',
     'e', 'a',
     'w', 'iu', 'l',
     'yr',
     'v', 'r',
     'c', 'u', 'f', 'b', 'lm',
     'eu', 'eo',
     'h',
    );

# ------------------------------------------------------------
# %aid_util::blank_entry -- a prototypical blank entry to clone
# ------------------------------------------------------------
%aid_util::blank_entry = ();
foreach my $key (@aid_util::edit_field_names)
{
    $aid_util::blank_entry{$key} = '';
}

$aid_util::blank_entry{'id'} = -1;     
$aid_util::blank_entry{'v'}  = 1;      
$aid_util::blank_entry{'r'}  = 1;      
$aid_util::blank_entry{'b'}  = 0;      
$aid_util::blank_entry{'lm'} = 0;      
$aid_util::blank_entry{'eu'} = 0;      
$aid_util::blank_entry{'n'}  = '';     

my %image_tag =
    (
     'new'	=>	'<span class="label label-success">NEW</span>',
     'updated'	=>	'<span class="label label-success">UPDATED</span>',
     'vcard'	=>	'View vCard',
     'info'	=>	'<b class="i">[i]</b>',
     'blank'	=> 	'<b>&nbsp;&nbsp;&nbsp;</b>',
     );

# give 'em back the configuration variable they need
sub config
{
    my($i) = @_;

    die "NO CONFIG $i!" if !defined($aid_util::config{$i});
    $aid_util::config{$i};
}

# give 'em back the image_tag they need
sub image_tag
{
    my($i) = @_;

    die "NO IMAGE_TAG $i!" if !defined($image_tag{$i});
    $image_tag{$i};
}

sub caldate
{
    my($time) = @_;

    POSIX::strftime("%e-%b-%Y", localtime($time));
}

sub vdate
{
    my($time) = @_;

    my($sec,$min,$hour,$day,$month,$year) = gmtime($time);
    sprintf("%d%02d%02dT%02d%02d%02dZ", $year+1900, $month+1, $day,
	    $hour, $min, $sec);
}

# is the GMT less than one month ago?
# 2678400 = 31 days * 24 hrs * 60 mins * 60 secs
sub is_new
{
    my($time,$months) = @_;

    $months = 1 unless $months;
    (((time - $time) < ($months * 2678400)) ? 1 : 0);
}


# is the GMT more than 6 months ago?
# 15724800 = 182 days * 24 hrs * 60 mins * 60 secs
sub is_old
{
    my($time) = @_;

    (((time - $time) >= 15724800) ? 1 : 0);
}

sub is_new_html
{
    my($rec) = @_;

    if (is_new($rec->{'u'}))
    {
	if (is_new($rec->{'c'}))
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

sub fullname
{
    my($rec) = @_;
    my($mi) = ($rec->{'mi'} ne '') ? ' ' . $rec->{'mi'} . '.' : '';

    if ($rec->{'gn'} eq '') {
	$rec->{'sn'};
    } else {
	if ($rec->{'mn'} ne '') {
	    sprintf('%s (now %s), %s%s',
		    $rec->{'sn'}, $rec->{'mn'}, $rec->{'gn'}, $mi);
	} else {
	    sprintf('%s, %s%s',
		    $rec->{'sn'}, $rec->{'gn'}, $mi);
	}
    }
}

sub protect_email
{
    my($e) = @_;

    my($u,$d) = split(/\@/, $e, 2);
    substr($u, 0, 5) . "...@" . substr($d, 0, 1) . "...";
}

sub inorder_fullname
{
    my($rec) = @_;
    my($mi) = ($rec->{'mi'} ne '') ? ' ' . $rec->{'mi'} . '.' : '';

    if ($rec->{'gn'} eq '') {
	$rec->{'sn'};
    } else {
	if ($rec->{'mn'} ne '') {
	    sprintf('%s%s %s (now %s)',
		    $rec->{'gn'}, $mi, $rec->{'sn'}, $rec->{'mn'});
	} else {
	    sprintf('%s%s %s',
		    $rec->{'gn'}, $mi, $rec->{'sn'});
	}
    }
}


sub affiliate
{
    my($rec,$do_html_p) = @_;
    my($year,$affil,$len,$tmp);

    $affil = '  ';
    $len   = 2;

    if ($rec->{'yr'} =~ /^\d+$/)
    {
	$affil .= "<a href=\"" .
	    about_path($rec,1) . "\">" 
	    if $do_html_p;
	$year = sprintf("%02d", $rec->{'yr'} % 100);

	$tmp = "'" . $year;
	$affil .= $tmp;
	$len   += length($tmp);

	$affil .= "</a>" if $do_html_p;

    }
    else
    {
	$affil .= "<a href=\"" .
	    about_path($rec,1) . "\">" 
	    if $do_html_p;
	$tmp    = '[' . $aid_util::config{'short_school'} . ' ' . $rec->{'yr'} . ']';
	$affil .= $tmp;
	$len   += length($tmp);
	$affil .= "</a>" if $do_html_p;
    }

    ($affil,$len);
}


# remove punctuation, hyphens, parentheses, and quotes.
sub mangle
{
    my($name) = @_;

    $name =~ s/\s+//g;
    $name =~ s/[^\d\w-]//g;

    $name;
}


sub ampersand_join
{
    my($rec) = @_;
    my($key,$val,$retval);

    $retval = 'id=' . url_escape($rec->{'id'}); 

    foreach my $f (@aid_util::edit_field_names)
    {
	next if $f eq 'id';
	$retval .= '&' . $f   . '=' . url_escape($rec->{$f}); 
    }
    
    $retval . '&n=' . url_escape($rec->{'n'}); 
}

sub generate_alias
{
    my($rec) = @_;

    my($a7,$alias);
    if (defined $rec->{'a'} && $rec->{'a'} ne '') {
	$alias = lc($rec->{'a'});
	$a7 = substr($alias, 0, 7);
    } else {
	my($mangledLast,$mangledFirst);

	$mangledFirst = mangle($rec->{'gn'}); 
	if ($rec->{'mn'} ne '') {
	    $mangledLast = mangle($rec->{'mn'});   
	} else {
	    $mangledLast = mangle($rec->{'sn'});   
	}

	$alias = lc(substr($mangledFirst, 0, 1) . $mangledLast);
	$a7 = substr($alias, 0, 7);
    }

    if (defined($aid_util::aid_aliases{$a7})) {
	$aid_util::aid_aliases{$a7}++;
	$alias = $a7 . $aid_util::aid_aliases{$a7};
    } else {
	$aid_util::aid_aliases{$a7} = 1;
    }

    $alias;
}

sub vcard_path
{
    my($rec) = @_;

    $aid_util::config{'vcard_cgi'} . '/' . $rec->{'id'} . '/' . 
	mangle($rec->{'gn'}) . mangle($rec->{'sn'}) . 
	    mangle($rec->{'mn'}) . '.vcf';
}

sub about_path
{
    my($rec,$class_page) = @_;

    if ($class_page)
    {
	my($page) = ($rec->{'yr'} =~ /^\d+$/) ? $rec->{'yr'} : 'other';

	"$aid_util::config{'master_path'}class/${page}.html";
    }
    else
    {
	sprintf("%s%s/%06d.html",
		$aid_util::config{'master_path'}, "detail", $rec->{'id'});
    }
}

sub html_entify_str
{
    my($str) = @_;

    $str =~ s/&/&amp;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    $str =~ s/"/&quot;/g; #"#
    $str =~ s/\s+/ /g;

    $str;
}

sub html_entify_rec
{
    my($rec_arg) = @_;
    my %rec = %{$rec_arg};

    foreach my $k (keys %rec)
    {
	$rec{$k} =~ s/&/&amp;/g;
	$rec{$k} =~ s/</&lt;/g;
	$rec{$k} =~ s/>/&gt;/g;
	$rec{$k} =~ s/"/&quot;/g; #"#
	$rec{$k} =~ s/\s+/ /g unless $k eq 'n';
    }

    %rec;
}

sub email_name
{
    my($rec) = @_;

    my $name = $rec->{'gn'};
    $name .= " $rec->{'mi'}."
	if defined $rec->{'mi'} && $rec->{'mi'} ne '';
    $name .= " $rec->{'sn'}";
    $name .= " $rec->{'mn'}"
	if defined $rec->{'mn'} && $rec->{'mn'} ne '';
    $name =~ s/\"/\'/g;
    return $name;
}

sub verification_message
{
    my($randkey,$rec,$is_delete) = @_;

    my $name = email_name($rec);
    my($return_path,$from,$subject,$xtrahead,$body,$recip);

    my($action1,$action2,$url);
    if ($is_delete) {
	$action1 = "requested deletion of your profile from";
	$action2 = "delete";
	$url = sprintf('%s?id=%d&k=%s&commit=2', $aid_util::config{"delete_cgi"}, $rec->{"id"}, $randkey);
    } else {
	$action1 = "submitted a profile on";
	$action2 = "publish";
	$url = sprintf('%s?%s', $aid_util::config{"verify_cgi"}, $randkey);
    }

    $body = inorder_fullname($rec) . ",

You recently $action1 the "
    . $aid_util::config{'short_school'} . " Alumni
Directory website. Please click the following link to
$action2 your profile:

http://" . $aid_util::config{'master_srv'} . $url ."

WAS THIS EMAIL SENT TO THE WRONG ADDRESS?

If you did not request a profile on the "
    . $aid_util::config{'short_school'} . " Alumni
Directory website, please ignore this message
with our apologies.

Regards,

" . $aid_util::config{'short_school'} . " Alumni Directory
http://" . $aid_util::config{'master_srv'} . $aid_util::config{'master_path'} . "\n";

    $return_path = $aid_util::config{'devnull_email'};
    $from = $aid_util::config{'short_school'} . ' Alumni Robot';
    $subject = $aid_util::config{'short_school'} .
	" Alumni Directory - action required to $action2 your profile";
    $xtrahead = "Reply-To: " . $aid_util::config{'devnull_email'};

    ($return_path,$from,$subject,$xtrahead,$body,$name,$rec->{'e'});
}


sub sendmail
{
    my($return_path,$from,$subject,$body,@recip) = @_;

    sendmail_v2($return_path,$from,$subject,'',$body,@recip);
}

sub sendmail_v2
{
    my($return_path,$from,$subject,$xtrahead,$body,@recip) = @_;
    my($message,$i,$to,$cc,@targets);

    my $smtp = Net::SMTP::SSL->new($aid_util::config{"smtp_svr"},
				   Port => 465,
				   Timeout => 15);
    unless ($smtp) {
	warn "smtp new() failure for $aid_util::config{'smtp_svr'}\n";
	return 0;
    }

    # try smtp auth and see if this fixes things
    $smtp->auth($aid_util::config{'smtp_user'},
		$aid_util::config{'smtp_pass'});

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

    if (!$HOSTNAME) {
	$HOSTNAME = `/bin/hostname -f`;
	chomp($HOSTNAME);
    }

    my $mid = "AID.$VERSION." . time() . ".$$\@$HOSTNAME";

    $message =
"From: $from <$return_path>
To: $to
${cc}Organization: $aid_util::config{'school'} Alumni Directory
${xtrahead}MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
X-Mailer: alumni internet directory mail v$VERSION
Message-ID: <$mid>
Subject: $subject
";

#    my($login) = getlogin() || getpwuid($<) || "UNKNOWN";
#    my($hostname) = $ENV{'HOST'} || `/bin/hostname`;
#    $message .= "X-Sender: $login\@$hostname\n";

    $message .= "\n" . main::encode_qp($body);

    unless ($smtp->mail($return_path)) {
	warn "smtp mail() failure for @targets\n";
        return 0;
    }
    foreach my $tgt (@targets) {
	unless($smtp->to($tgt)) {
	    warn "smtp to() failure for $tgt\n";
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


sub verbose_entry
{
    my($rec_arg,$display_year,$suppress_new,$suppress_links,$suppress_name,
       $show_email) = @_;

    my %rec = html_entify_rec($rec_arg);

    my $fullname = inorder_fullname(\%rec);

    my $retval = qq{<div id="id-$rec{'id'}">\n};

    if (! $suppress_name) {
	$retval .= "<h3>$fullname";
	$retval .= is_new_html(\%rec) unless $suppress_new; 
	$retval .= "</h3>\n";
    }

    $retval .= qq{<ul class="list-unstyled">\n};

    if ($rec{'yr'} =~ /^\d+$/) {
	if ($display_year) {
	    $retval .= "<li>Year: <strong><a\n" .
		"href=\"" . about_path(\%rec,1) . "\">" . 
		    $rec{'yr'} . "</a></strong>";
	$retval .= "</li>";
	$retval .= "\n";

	}
    } else {
	$retval .= "<li>Affiliation: <strong><a\n" .
	    "href=\"" . about_path(\%rec,1) . "\">" . 
		$rec{'yr'} . "</a></strong>";
	$retval .= "</li>";
	$retval .= "\n";

    }

    $retval .= "<li>E-mail: <tt><strong>";
    $retval .= ("<a\ntitle=\"Send a message to $fullname\"\nhref=\"" .
		about_path(\%rec, 0) . "#msg" .
		"\">")
	if $rec{'v'} && $rec{'id'} > 0;
    if ($show_email) {
	$retval .= $rec{'e'};
    } else {
	$retval .= protect_email($rec{'e'});
    }
    $retval .= "</a>" if $rec{'v'};
    $retval .= "\n<em>(e-mail bouncing)</em>" unless $rec{'v'};
    $retval .= "</strong></tt>";
    $retval .= "</li>";
    $retval .= "\n";

    $retval .= "<li>Web Page: <tt><strong><a\n" . 
	"href=\"$rec{'w'}\">$rec{'w'}</a></strong></tt>\n"
	    if $rec{'w'} ne '';
    $retval .= "<li>Location: <strong>$rec{'l'}</strong>\n"
	if $rec{'l'} ne '';
    $retval .= "<li>Updated: ";
    my $date = caldate($rec{'u'}); 
    $retval .= "<strong>$date</strong>";
    $retval .= "</li>";
    $retval .= "\n";

    if (! $suppress_links)
    {
	$retval .= "<li>Tools: <small>" .
	    "<a\nhref=\"" . $aid_util::config{'about_cgi'} .
	    "/$rec{'id'}\">modify profile</a>" . 
	    " | <a\nhref=\"" . $aid_util::config{'delete_cgi'} .
	    "?id=$rec{'id'}\">delete profile</a>" . 
	    "</small>";
	$retval .= "\n";
    }

    if ($rec{'n'} ne '') {
	$retval .= "<li><strong>What's New?</strong>\n";
	$rec{'n'} =~ s/[ ]*\n/<br>\n/g;
	$retval .= "<p>$rec{'n'}</p>\n";
    }
    $retval .= "</ul>\n";
    $retval .= "</div><!-- #id-$rec{'id'} -->\n\n";

    $retval;
}


sub vcard_text
{
    my($rec) = @_;
    my($v_fn,$v_n,$retval);
    my($mi) = ($rec->{'mi'} ne '') ? "$rec->{'mi'}. " : '';
    my($v_mi) = ($rec->{'mi'} ne '') ? ";$rec->{'mi'}" : '';

    # "N:Public;John;Quinlan;Mr.;Esq." ==> "FN:Mr. John Q. Public, Esq."
    if ($rec->{'mn'} ne '') {
	$v_n  = "N:$rec->{'mn'};$rec->{'gn'};$rec->{'sn'}\015\012";
	$v_fn = "FN:$rec->{'gn'} ${mi}$rec->{'sn'} $rec->{'mn'}\015\012";
    } else {
	$v_n  = "N:$rec->{'sn'};$rec->{'gn'}${v_mi}\015\012";
	$v_fn = "FN:$rec->{'gn'} ${mi}$rec->{'sn'}\015\012";
    }

    $retval  = "Begin:vCard\015\012";
    $retval .= $v_n;
    $retval .= $v_fn;
    $retval .= "ORG:" . $aid_util::config{'short_school'} . ";";
    if ($rec->{'yr'} =~ /^\d+$/) {
	$retval .= "Class of $rec->{'yr'}\015\012";
    } else {	
	$retval .= "$rec->{'yr'}\015\012";
    }
    $retval .= "EMAIL;PREF;INTERNET:$rec->{'e'}\015\012";
    if ($rec->{'l'} =~ /^(.*),\s+(\w\w)$/) {
	$retval .= "ADR:;;;$1;\U$2\E\015\012";
    } else {
	$retval .= "ADR:;;;$rec->{'l'}\015\012" if $rec->{'l'} ne '';
    }
    $retval .= "URL:$rec->{'w'}\015\012" if $rec->{'w'} ne '';
    $retval .= "REV:" . vdate($rec->{'u'}) . "\015\012"; 
    $retval .= "VERSION:2.1\015\012";

#    if ($rec->{'n'} !~ /^\s*$/)
#    {
#	$retval .= "NOTE;BASE64:\015\012";
#	$retval .= "  ";
#	$message = main::encode_base64($rec->{'n'}, "\015\012  ");
#	substr($message,-4) = '';
#	$retval .= $message . "\015\012\015\012";
#    }
    $retval .= "End:vCard\015\012";

    $retval;
}


sub about_text
{
    my($rec) = @_;

    my($retval) = '';
    $retval .= inorder_fullname($rec) . "\n";

    if ($rec->{'yr'} =~ /^\d+$/) {
	$retval .= $aid_util::config{'short_school'} . " Class of " . $rec->{'yr'} . "\n";
    } else {
	$retval .= "Affiliation: " . $rec->{'yr'} . "\n\n";
    }

    $retval .= "E-mail: " . $rec->{'e'} . "\n";

    if ($rec->{'w'} ne '' || $rec->{'l'} ne '') {
	$retval .= "Web Page: " . $rec->{'w'} . "\n"
	    if $rec->{'w'} ne '';
	$retval .= "Location: " . $rec->{'l'} . "\n"
	    if $rec->{'l'} ne '';
	$retval .= "\n";
    }

    if ($rec->{'n'} ne '') {
	$retval .= "What's New?\n-----------\n" . $rec->{'n'} . 
	    "\nLast Updated: " . caldate($rec->{'u'}) . "\n";
    } else {
	$retval .= "Last Updated: " . caldate($rec->{'u'}) . "\n"; 
    }

    $retval .= "\nPreferences\n-----------\n";
    $retval .= "My class officers may send me reunion info via e-mail:\n";
    $retval .= ($rec->{'r'} == 1) ? " --> yes\n" : " --> no\n";

    $retval;
}

sub common_intro_para
{
    my($page) = @_;
    my($info) = "The <tt>" . $image_tag{'info'} .
	"</tt>\nicon lets you get more detailed information about an alumnus.";

    "<p><small>Any alumni marked with\n" . $image_tag{'new'} . 
    "\nhave been added to the Directory last month.\n" .
    "Alumni marked with\n" . $image_tag{'updated'} . 
    "\nhave updated their information within the past month.\n" .
    ($page ? $info : '') .
    "</small></p>\n";
}

sub common_html_ftr
{
    my($page,$time) = @_;
    my($ftr);
    my($year) = (localtime(time))[5] + 1900;

    $time = time unless (defined $time && $time =~ /\d+/ && $time ne '0');

    $ftr  = qq{<footer>\n<hr>\n};

    $ftr .= "<!-- hhmts start -->\nLast modified: ";
    $ftr .= scalar(localtime($time)) . "\n";
    $ftr .= "<!-- hhmts end -->\n<br>\n";
    $ftr .=
	"Copyright &copy; $year " . $aid_util::config{'admin_name'} . 
	".  All rights reserved.\n" .
	"<a\nhref=\"" . $aid_util::config{'master_path'} .
	"etc/privacy.html\">Privacy Policy</a> - " .
	"<a\nhref=\"" . $aid_util::config{'master_path'} .
	"etc/tos.html\">Terms of Service</a>" .
	"\n";
    
    $ftr .= "</footer>\n";
    $ftr .= "</div><!-- .container -->\n";
    $ftr .= <<EOHTML;
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
EOHTML
;
    $ftr .= "</body>\n</html>\n";

    $ftr;
}


sub common_html_hdr
{
    my($page,$title,$norobots,$time,$subtitle,$extra_meta,$nohtmlize) = @_;
    my($hdr,$titletag,$srv_nowww,$descr);
    my($timestamp) =
	caldate((defined $time && $time ne '') ? $time : time); 

    $title = html_entify_str($title) unless $nohtmlize;
    $subtitle = html_entify_str($subtitle)
	if defined $subtitle && !$nohtmlize;

    $titletag = ($page == 0) ?
	($aid_util::config{'school'} . " Alumni Directory") :
	($title . " - " . $aid_util::config{'short_school'} . " Alumni");

    $hdr  = 
	"<!DOCTYPE html>\n" .
	"<html lang=\"en\">\n" .
	"<head>\n<title>" . $titletag . "</title>\n";

    $hdr .= qq{<meta name="viewport" content="width=device-width, initial-scale=1.0">\n};

    # do stylesheet before the rest of the meta tags on the theory that
    # early evaluation is good
    $hdr .= qq{<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css">\n};

    $hdr .= $aid_util::author_meta . "\n" . $aid_util::navigation_meta .
	"\n";

    if (! $norobots)
    {
	$descr = $aid_util::descr_meta;
	$descr =~ s/__DATE__/$timestamp/g;
	$hdr .= $descr;
    }

    $hdr .= $extra_meta if defined $extra_meta;
    $hdr .= "\n<base target=\"_top\"></head>\n";
    
    $hdr .= "<body>\n";

    $srv_nowww =  $aid_util::config{'master_srv'};
    $srv_nowww =~ s/^www\.//i;

    my $master_class = ($page == 0) ? qq{ class="active"} : "";

    my $breadcrumbs = "";
    if (defined $aid_util::parent_page_name{$page}) {
	$breadcrumbs .=
	    '      <li><a href="' . $aid_util::parent_page_path{$page} . '">' .
	    $aid_util::parent_page_name{$page} . "</a></li>\n";
    }
    $breadcrumbs .= qq{      <li class="active"><a href="#">$title</a></li>\n} unless $page == 0;

    $hdr .= <<EOHTML;
<div class="navbar navbar-default navbar-static-top" role="navigation">
 <div class="container">
  <div class="navbar-header">
    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
      <span class="sr-only">Toggle navigation</span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
    </button>
    <a class="navbar-brand" href="/">$srv_nowww</a>
  </div>
  <div class="collapse navbar-collapse">
    <ul class="nav navbar-nav">
      <li${master_class}><a href="$aid_util::config{'master_path'}">$aid_util::config{'short_school'} Alumni</a></li>
$breadcrumbs
    </ul>
    <form class="navbar-form navbar-right" role="search" method="get" action="$aid_util::config{'search_cgi'}">
      <div class="form-group">
        <input type="text" name="q" class="form-control" placeholder="Search">
      </div>
      <button type="submit" class="btn btn-primary">Search</button>
    </form>
  </div><!-- .navbar-collapse -->
 </div>
</div><!-- .navbar -->
EOHTML
;

    $hdr .= qq{<div class="container">\n};

    if ($page == 0)
    {
	$hdr .= "<h1>$aid_util::config{'school'}\n";
	$hdr .= "Alumni Directory</h1>";
    }
    else
    {
	$hdr .= "<h1 class=\"page-header\">$title";
	$hdr .= "\n<small>$subtitle</small>"
	    if defined $subtitle && $subtitle ne '';
	$hdr .= "</h1>";
    }

    $hdr .= "\n";

    $hdr;
}

sub class_jump_bar
{
    my($href_begin,$href_end,$years,$do_paragraph,$hilite) = @_;
    my $retval = "";

    if (defined @{$years} && defined $years->[0])
    {
	$retval .= qq{<a name="top"></a>};
	$retval .= qq{<ul class="pagination">\n};

	foreach my $i (0 .. (scalar(@{$years}) - 1))
	{
	    my $label = ($years->[$i] eq 'other') ? "Faculty/Staff" :
		sprintf("%02d", $years->[$i] % 100);
	    $retval .= qq{<li};
	    $retval .= qq{ class="active"} if defined $hilite && $years->[$i] eq $hilite;
	    $retval .= qq{><a href="} . $href_begin . $years->[$i] . $href_end . qq{">};
	    $retval .= $label;
	    $retval .= "</a>\n";
	}

	$retval .= qq{</ul>\n};
	$retval .= "\n";
    }

    $retval;
}



sub book_write_prefix
{
    my($BOOKfh,$option) = @_;
    my($school) = $aid_util::config{'school'};

    # special case for netscape
    if ($option eq 'n') {
	print $BOOKfh "<!DOCTYPE NETSCAPE-Addressbook-file-1>
<!-- This is an automatically generated file.
It will be read and overwritten.
Do Not Edit! -->
<TITLE>$school Alumni Address book</TITLE>
<H1>$school Alumni Address book</H1>

<DL><p>\n";
    }

    elsif ($option eq 'o') {
	print $BOOKfh
	    "\"Title\",\"First Name\",\"Middle Name\",\"Last Name\",\"Suffix\",\"Company\",\"Department\",\"Job Title\",\"Business Street\",\"Business Street 2\",\"Business Street 3\",\"Business City\",\"Business State\",\"Business Postal Code\",\"Business Country\",\"Home Street\",\"Home Street 2\",\"Home Street 3\",\"Home City\",\"Home State\",\"Home Postal Code\",\"Home Country\",\"Other Street\",\"Other Street 2\",\"Other Street 3\",\"Other City\",\"Other State\",\"Other Postal Code\",\"Other Country\",\"Assistant's Phone\",\"Business Fax\",\"Business Phone\",\"Business Phone 2\",\"Callback\",\"Car Phone\",\"Company Main Phone\",\"Home Fax\",\"Home Phone\",\"Home Phone 2\",\"ISDN\",\"Mobile Phone\",\"Other Fax\",\"Other Phone\",\"Pager\",\"Primary Phone\",\"Radio Phone\",\"TTY/TDD Phone\",\"Telex\",\"Account\",\"Anniversary\",\"Assistant's Name\",\"Billing Information\",\"Birthday\",\"Categories\",\"Children\",\"E-mail Address\",\"E-mail Display Name\",\"E-mail 2 Address\",\"E-mail 2 Display Name\",\"E-mail 3 Address\",\"E-mail 3 Display Name\",\"Gender\",\"Government ID Number\",\"Hobby\",\"Initials\",\"Keywords\",\"Language\",\"Location\",\"Mileage\",\"Notes\",\"Office Location\",\"Organizational ID Number\",\"PO Box\",\"Private\",\"Profession\",\"Referred By\",\"Spouse\",\"User 1\",\"User 2\",\"User 3\",\"User 4\",\"Web Page\"\015\012";
    } elsif ($option eq 'T') {
	print $BOOKfh "Last Name\tFirst Name\tE-mail Address\015\012";
    }
}

sub book_write_entry
{
    my($BOOKfh,$option,$rec) = @_;
    my($long_last) = $rec->{'sn'};
    my($mi) = $rec->{'mi'} ne '' ? "$rec->{'mi'}." : '';

    $long_last .= " $rec->{'mn'}" if $rec->{'mn'} ne '';
    $long_last =~ s/\"/\'/g;
    $long_last =~ s/[,;\t]/ /g;

    my($gn) = $rec->{'gn'};
    $gn =~ s/\"/\'/g;
    $gn =~ s/[,;\t]/ /g;

    $option eq 'T' && print $BOOKfh "$long_last\t$gn\t$rec->{'e'}\r\n";
    $option eq 't' && print $BOOKfh "$rec->{'e'}\r\n";
    $option eq 'p' && print $BOOKfh "$rec->{'a'}\t$long_last, $gn\t$rec->{'e'}\t\t$aid_util::config{'short_school'} $rec->{'yr'}\n";
    $option eq 'e' && print $BOOKfh "$rec->{'a'} = $long_last; $gn, $aid_util::config{'short_school'} $rec->{'yr'} = $rec->{'e'}\n";
    $option eq 'b' && print $BOOKfh "alias $rec->{'a'}\t$rec->{'e'}\n";
    $option eq 'w' && print $BOOKfh "<$rec->{'a'}>\015\012>$gn $long_last <$rec->{'e'}>\015\012<$rec->{'a'}>\015\012>$aid_util::config{'short_school'} $rec->{'yr'}\015\012";
    $option eq 'm' && print $BOOKfh "alias $rec->{'a'} $rec->{'e'}\015\012note $rec->{'a'} <name:$gn $long_last>$aid_util::config{'short_school'} $rec->{'yr'}\015\012";

    # netscape is a bigger sucker
    if ($option eq 'n') {
	print $BOOKfh "    <DT><A HREF=\"mailto:$rec->{'e'}\" ";
	print $BOOKfh "NICKNAME=\"$rec->{'a'}\">$gn $long_last</A>\n";
	print $BOOKfh "<DD>$aid_util::config{'short_school'} $rec->{'yr'}\n";
    }

    elsif ($option eq 'l') {
        print $BOOKfh "dn: cn=$gn $long_last,mail=$rec->{'e'}\015\012";
	print $BOOKfh "modifytimestamp: ";
	my $vdate = vdate($rec->{'u'}); 
	$vdate =~ s/T//;
	print $BOOKfh "$vdate\015\012";
        print $BOOKfh "cn: $gn $long_last\015\012";
	if ($rec->{'mn'} ne '') {
	    print $BOOKfh "sn: $rec->{'mn'}\015\012";
	} else {
	    print $BOOKfh "sn: $rec->{'sn'}\015\012";
	}
        print $BOOKfh "givenname: $gn\015\012";
        print $BOOKfh "objectclass: top\015\012objectclass: person\015\012";
        print $BOOKfh "mail: $rec->{'e'}\015\012";
	if ($rec->{'l'} =~ /^(.*),\s+(\w\w)$/) {
	    print $BOOKfh "locality: $1\015\012";
	    print $BOOKfh "st: $2\015\012";
	} else {
	    print $BOOKfh "locality: $rec->{'l'}\015\012" if $rec->{'l'} ne '';
	}
        print $BOOKfh "o: $aid_util::config{'short_school'}\015\012";
	if ($rec->{'yr'} =~ /^\d+$/) {
	    print $BOOKfh "ou: Class of $rec->{'yr'}\015\012";
	} else {
	    print $BOOKfh "ou: $rec->{'yr'}\015\012";
	}
        print $BOOKfh "homeurl: $rec->{'w'}\015\012" if $rec->{'w'} ne '';
        print $BOOKfh "xmozillanickname: $rec->{'a'}\015\012";
        print $BOOKfh "\015\012";
    }
    
    # lots of data for a vCard
    elsif ($option eq 'v') {
	print $BOOKfh vcard_text($rec), "\015\012"; 
    }

    elsif ($option eq 'o') {
	my %rec_copy = %{$rec};
	$rec_copy{'gn'} =~ s/\"/\'/g;
	$rec_copy{'sn'} =~ s/\"/\'/g;
	$rec_copy{'mn'} =~ s/\"/\'/g;
	$mi =~ s/\"/\'/g;

	print $BOOKfh "\"\",\"$rec_copy{'gn'}\",";
	if ($rec_copy{'mn'} ne '') {
	    print $BOOKfh "\"$rec_copy{'sn'}\",\"$rec_copy{'mn'}\",";
	} else {
	    print $BOOKfh "\"$mi\",\"$rec_copy{'sn'}\",";
	}

	print $BOOKfh "\"\",\"$aid_util::config{'short_school'} $rec->{'yr'}\",\"\",";
	print $BOOKfh "\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",";

	if ($rec->{'l'} =~ /^(.*),\s+(\w\w)$/) {
	    print $BOOKfh "\"$1\",\"$2\",";
	} else {
	    print $BOOKfh "\"$rec->{'l'}\",\"\",";
	}

	print $BOOKfh "\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"$aid_util::config{'short_school'} Alumni\",\"\",\"$rec->{'e'}\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"$rec->{'w'}\"\015\012";
    }
}

sub book_write_suffix
{
    my($BOOKfh,$option) = @_;

    $option eq 'n' && print $BOOKfh "</DL><p>\n";
}

sub url_unescape
{
    my($u) = @_;

    # Convert plus to space
    $u =~ s/\+/ /g;

    # Convert %XX from hex numbers to alphanumeric
    $u =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;

    $u;
}


sub url_escape
{
    my($u) = @_;

    $u =~ s/([^\w\$. -])/sprintf("%%%02X", ord($1))/eg;
    $u =~ s/ /+/g;

    $u;
}

sub cgi_die
{
    my($title,$html) = @_;

    print "Content-Type: text/html\015\012\015\012";

    print common_html_hdr(-1,$title,1);
    print "<p>", $html, "<p>\n" if (defined $html && $html !~ /^\s*$/);
    print common_html_ftr(-1);

    close(STDOUT);
    exit(0);
}

sub Normalize_Delta_YMD
{
    my($date1,$date2) = @_;
    my(@delta);

    @delta = Date::Calc::Delta_YMD(@$date1,@$date2);
    while ($delta[1] < 0 or $delta[2] < 0)
    {
	if ($delta[1] < 0) { $delta[0]--; $delta[1] += 12; }
	if ($delta[2] < 0)
	{
	    $delta[1]--;
	    $delta[2] = Date::Calc::Delta_Days(Date::Calc::Add_Delta_YM(@$date1,@delta[0,1]),@$date2);
	}
    }
    return \@delta;
}

sub write_reunion_hash
{
    my($FH,$entries) = @_;
    my($key);

    foreach $key (sort keys %{$entries})
    {
	my $clean_key;
	if ($key =~ /^\d+$/) {
	    $clean_key = $key;
	} else {
	    $clean_key = lc($key);
	    $clean_key =~ s/[^\w]/_/g;
	    $clean_key =~ s/_+/_/g;
	    $clean_key =~ s/^_//;
	    $clean_key =~ s/_$//;
	}

	print $FH qq{<div id="r$clean_key">\n};

	print $FH "<h4>", config('school');

	if ($key =~ /^\d+$/)
	{
	    print $FH " <a href=\"", 
	    config('master_path'),
	    "class/$key.html\">Class of $key</a>";
	}
	else
	{
	    print $FH " - $key";
	}

	print $FH qq{ Reunion</h4>\n<ul class="list-unstyled">\n<li>Date: };

	my($date,$html) = split(/\0/, $entries->{$key}, 2);
	my($year,$mon,$mday,$t) = (0,0,0,0);

	if ($date eq "TBA")
	{
	    print $FH "TBA";
	}
	else
	{
	    ($year,$mon,$mday) = split(/\//, $date, 3);
	    $t = Time::Local::timelocal(59,59,23,$mday,$mon-1,$year-1900);

	    print $FH POSIX::strftime("%A, %B %e, %Y", localtime($t));

	    if ($t < time())
	    {
		my $today = [Date::Calc::Today()];
		my $target = [$year,$mon,$mday];
		my $delta = Normalize_Delta_YMD($target,$today);
		print $FH " <em>(";
		if ($delta->[0] == 1) {
		    print $FH "1 year";
		} elsif ($delta->[0] > 0) {
		    print $FH "$delta->[0] years";
		}
		if ($delta->[1] == 1) {
		    print $FH ", " if $delta->[0] > 0;
		    print $FH "1 month";
		} elsif ($delta->[1] > 0) {
		    print $FH ", " if $delta->[0] > 0;
		    print $FH "$delta->[1] months";
		}
		print $FH " ago)</em>";
	    }
	}
	print $FH "</li>\n";

	$html =~ s/\@/&#64;/g;	# protect email addresses

	print $FH $html, "\n</ul>\n<br><br>\n</div><!-- #r$clean_key -->\n\n";
    }

    1;
}

sub die_if_failure
{
    my($exit_value) = $? >> 8;
    my($signal_num) = $? & 127;
    die "\nKilled with signal $signal_num\n" if $signal_num;
    die "Exited with $exit_value\n" if $exit_value;

    1;
}

my $connected = 0;
my $dbh;

sub db_connect {
    if (!$connected) {
	my $dbname = config("dbname");
	my $dbhost = config("dbhost");
	my $dsn = "DBI:mysql:database=$dbname;host=$dbhost";
	$dbh = DBI->connect($dsn, config("dbuser"), config("dbpass"), {
                   PrintError => 0,
	       });
	if (defined $dbh) {
	    $connected = 1;
	}
    }

    $dbh;
}

sub load_years {
    my($dbh) = @_;

    my $sql = qq{
SELECT DISTINCT e.entry_gradclass
FROM aid_alumnus a, aid_entry e
WHERE a.alumnus_entry_id = e.entry_id
AND e.entry_gradclass IS NOT NULL
ORDER BY e.entry_gradclass ASC 
};

    my $sth = $dbh->prepare($sql);
    $sth->execute or die $sth->errstr;
    my $yearsref = $sth->fetchall_arrayref([0]);
    my @years = map { $_->[0] } @{$yearsref};

    # are there any "other" alumni?
    $sql = qq{
SELECT COUNT(e.entry_affil_other)
FROM aid_alumnus a, aid_entry e
WHERE a.alumnus_entry_id = e.entry_id
AND e.entry_affil_other IS NOT NULL
};
    $sth = $dbh->prepare($sql);
    $sth->execute or die $sth->errstr;
    my($count) = $sth->fetchrow_array;
    push(@years, "other") if $count;

    @years;
}

sub load_records
{
    my($dbh,$extra_sql) = @_;

    $extra_sql = "" unless defined $extra_sql;

    my %result;
    my $sql = <<EOSQL
SELECT
a.alumnus_id,a.alumnus_status,
UNIX_TIMESTAMP(a.alumnus_create),
UNIX_TIMESTAMP(a.alumnus_update),
e.entry_name_surname,e.entry_name_married,
e.entry_name_given,e.entry_name_mi,
e.entry_email,e.entry_gradclass,e.entry_affil_other,
e.entry_web_page,e.entry_location,e.entry_note,e.entry_reunion
FROM aid_alumnus a, aid_entry e
WHERE a.alumnus_entry_id = e.entry_id
$extra_sql
EOSQL
;

    if ($ENV{"AID_DEBUG"}) {
	warn $sql;
    }

    my $sth = $dbh->prepare($sql);
    $sth->execute or die $sth->errstr;
    while (my($id,$status,$ts_create,$ts_update,
	      $name_surname,$name_married,
	      $name_given,$name_mi,
	      $email,$gradclass,$affil_other,
	      $web_page,$location,$note_text,$reunion) =
	   $sth->fetchrow_array)
    {
	if ($note_text) {
	    $note_text =~ s/\r\n/\n/g;
	}
	my $yr = $gradclass ? $gradclass : $affil_other;
	my %rec = (
		   "id" => $id,
		   "v" => $status,
		   "sn" => $name_surname,
		   "mn" => $name_married,
		   "gn" => $name_given,
		   "mi" => $name_mi,
		   "r" => $reunion,
		   "b" => 0,
		   "c" => $ts_create,
		   "u" => $ts_update,
		   "f" => 0,
		   "yr" => $yr,
		   "e" => $email,
		   "w" => $web_page,
		   "l" => $location,
		   "n" => $note_text,
		   );

	foreach my $key (@aid_util::edit_field_names, "n") {
	    $rec{$key} = "" unless defined $rec{$key};
	}

	$result{$id} = \%rec;
    }

    \%result;
}

sub print_rss_head 
{
    my($fh,$time,$title,$link,$desc) = @_;

    my $lastBuildDate = POSIX::strftime("%a, %d %b %Y %H:%M:%S GMT",
					gmtime($time));

    $title = config("short_school") . " Alumni Directory"
	unless $title;
    $link = "http://" . config("master_srv")
	. config("master_path") . "recent.html"
	unless $link;
    $desc = config("descr_long")
	unless $desc;

    print $fh
"<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>
<rss version=\"2.0\">
<channel>
<title>$title</title>
<link>$link</link>
<description>$desc</description>
<language>en-us</language>
<lastBuildDate>$lastBuildDate</lastBuildDate>
";
}

sub print_rss_item
{
    my($fh,$rec) = @_;

    my($affil,$len) = affiliate($rec, 0);
    my $pubDate = POSIX::strftime("%a, %d %b %Y %H:%M:%S GMT",
				  gmtime($rec->{"u"}));

    print $fh "<item>\n<title>"
    .  html_entify_str(inorder_fullname($rec)) . html_entify_str($affil)
    . "</title>
<link>http://" . config("master_srv") . about_path($rec,0) . "</link>
<pubDate>$pubDate</pubDate>
<guid isPermaLink=\"false\">" . $rec->{"id"} . "," . $rec->{"u"} .
"\@" . config("master_srv") . config("master_path") . "</guid>
<description>Updated " . caldate($rec->{"u"}), ".";

    if ($rec->{"n"}) {
	print $fh " ", html_entify_str($rec->{"n"});
    }

    print $fh "</description>\n</item>\n";
}

sub delete_entry
{
    my($dbh,$recp,$dryrun) = @_;

    my $sql = "SELECT alumnus_entry_id,alumnus_old_id"
	. " FROM aid_alumnus WHERE alumnus_id = ?";
    if ($dryrun) {
	print $sql, " -- $recp->{id}\n";
    }
    my $sth = $dbh->prepare($sql);
    $sth->execute($recp->{"id"}) or die $sth->errstr;
    my($entry_id,$old_entry_id) = $sth->fetchrow_array;
    if (defined $entry_id) {
	$sql = "DELETE FROM aid_entry WHERE entry_id = ?";
	$sth = $dbh->prepare($sql);
	if ($dryrun) {
	    print $sql, " -- $entry_id\n";
	} else {
	    $sth->execute($entry_id) or die $sth->errstr;
	}
	if (defined $old_entry_id) {
	    if ($dryrun) {
		print $sql, " -- $old_entry_id\n";
	    } else {
		$sth->execute($old_entry_id) or die $sth->errstr;
	    }
	}
    }

    $sql = "DELETE FROM aid_alumnus WHERE alumnus_id = ?";
    if ($dryrun) {
	print $sql, " -- $recp->{id}\n";
    } else {
	$sth = $dbh->prepare($sql);
	$sth->execute($recp->{"id"}) or die $sth->errstr;
    }

    my $out2 = sprintf("%s%s/%06d.html",
		       aid_util::config("wwwdir"), "detail", $recp->{"id"});
    if (-e $out2) {
	if ($dryrun) {
	    print "/bin/rm -f $out2\n";
	} else {
	    unlink($out2);
	}
    }
}

1;

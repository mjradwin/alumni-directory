#
#     FILE: aid_submit.pm
#   AUTHOR: Michael J. Radwin
#    DESCR: submission form for Alumni Internet Directory
#      $Id: aid_submit.pm,v 6.6 2004/05/12 22:36:43 mradwin Exp mradwin $
#
# Copyright (c) 2003  Michael J. Radwin.
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
#  * Neither the name of the High School Alumni Internet Directory
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

use aid_util;
use strict;

package aid_submit;

sub submit_body
{
    my($rec_arg,$empty_fields) = @_;
    my($body,$instr);
    my(@reqradio,$i,$reunion_chk,@empty_fields,$prev_email);

    my %rec = aid_util::html_entify_rec($rec_arg);

    $prev_email = defined $rec{'pe'} ? 
	$rec{'pe'} : $rec{'e'};
    $rec{'w'} = 'http://' if $rec{'w'} eq '';

    # give defaults if they're being revalidated
    if ($rec{'v'} == 0)
    {
	$rec{'q'} = $aid_util::blank_entry{'q'};
	$rec{'r'} = $aid_util::blank_entry{'r'};
    }

    for ($i = 0; $i < @aid_util::req_descr_long; $i++) 
    {
	$reqradio[$i] = "
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=\"radio\" name=\"q\" id=\"q$i\"
  value=\"$i\"" . (($rec{'q'} == $i) ? ' checked' : '') .
  "><label for=\"q$i\">&nbsp;\n  $aid_util::req_descr_long[$i]\n  </label><br>\n";
    }

    $reunion_chk = ($rec{'r'} == 1) ? ' checked' : '';

    $body = '';

    if ($rec{'yr'} =~ /^\d+$/ && $rec{'yr'} > aid_util::config('max_gradyear'))
    {
	$body .= "<p><strong><font color=\"red\">Your graduating class\n" .
		 "(<code>" . $rec{'yr'} . "</code>)\n" .
		 "appears to be invalid.</font>\n" .
		 "<br>It must be no later than " .
		 aid_util::config('max_gradyear') .
		 ".</strong></p>\n\n";

	$empty_fields =~ s/\byr\b//g;
    }
    elsif ($rec{'yr'} =~ /^\d+$/ && $rec{'yr'} < 1900)
    {
	$body .= "<p><strong><font color=\"red\">Your graduating class\n" .
		 "(<code>" . $rec{'yr'} . "</code>)\n" .
		 "appears to be invalid.</font>\n" .
		 "<br>It must be no earlier than 1900" .
		 ".</strong></p>\n\n";

	$empty_fields =~ s/\byr\b//g;
    }

    if ($empty_fields ne '')
    {
	if ($empty_fields =~ /\be\b/ && $rec{'e'} !~ /^\s*$/)
	{
	    $body .= "<p><strong><font color=\"red\">Your e-mail address\n";
	    $body .= "(<code>" . $rec{'e'} . "</code>)\n";
	    $body .= "appears to be invalid.</font>\n";
	    $body .= "<br>It must be in the form of ";
	    $body .= "<code>user\@example.com</code>.\n";
	    if ($rec{'e'} !~ /\@/)
	    {
		$body .= "Perhaps you meant to type ";
		$body .= "<code>$rec{'e'}\@aol.com</code>?\n";
	    }
	    $body .= "</strong></p>\n\n";

	    $empty_fields =~ s/\be\b//g;
	}

	@empty_fields = split(/\s+/, $empty_fields);
	if (@empty_fields)
	{
	    $body .= "<p><font color=\"red\"><strong>It appears that\n";
	    $body .= "the following required fields were blank:";
	    $body .= "</strong></font></p>\n\n<ul>\n";

	    foreach my $ef (@empty_fields)
	    {
		$body .= "<li>" . $aid_util::field_descr{$ef} . "</li>\n";
	    }
	    $body .= "</ul>\n\n";
	}
    }

    my $star = "<font color=\"#$aid_util::star_fg\">*</font>";

    $instr = "<p>Please " . (($rec{'id'} != -1) ? "update" : "enter") .
    " the following information about yourself.<br>
Fields marked with a $star
are required.  All other fields are optional.</p>
";

    # special hack for MVHS
    $instr .= "<p><font color=\"red\">Are you an alumnus of Awalt High
School?</font>
Please add your listing  to the<br>
<a href=\"/awalt/\">Awalt High School Alumni Internet Directory</a>
instead.</p>
" if $rec{'id'} == -1 && aid_util::config('school') eq 'Mountain View High School';

    $body .= "\n<form method=\"post\" action=\"" . aid_util::config('submit_cgi');
    $body .= "/$rec{'id'}" if $rec{'id'} != -1;
    $body .= "/new" if $rec{'id'} == -1;
    $body .= "\">\n\n" . $instr . "\n\n";
    
    my $ss = aid_util::config('short_school');
    my $mp = aid_util::config('master_path');

    $body .= "<table border=\"0\" cellspacing=\"7\">

<tr><td colspan=\"3\" bgcolor=\"#$aid_util::header_bg\">
<font color=\"#$aid_util::header_fg\"><big><strong class=\"hl\">1.
Full Name</strong></big></font>
</td></tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"gn\"><strong>First Name:</strong></label></td>
  <td valign=\"top\">$star</td>
  <td valign=\"top\"><input type=\"text\" name=\"gn\" size=\"35\" 
  value=\"$rec{'gn'}\" id=\"gn\"></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"mi\"><strong>Middle Initial:</strong></label></td>
  <td>&nbsp;</td>
  <td valign=\"top\"><input type=\"text\" name=\"mi\" size=\"1\" maxlength=\"1\"
  value=\"$rec{'mi'}\" id=\"mi\"></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label 
  for=\"sn\"><strong>Last Name/Maiden Name:</strong></label><br>
  <small>(your last name in high school)</small></td>
  <td valign=\"top\">$star</td>
  <td valign=\"top\"><input type=\"text\" name=\"sn\" size=\"35\"
  value=\"$rec{'sn'}\" id=\"sn\"></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"mn\"><strong>Married Last Name:</strong></label><br>
  <small>(if different from maiden name)</small></td>
  <td>&nbsp;</td>
  <td valign=\"top\"><input type=\"text\" name=\"mn\" size=\"35\"
  value=\"$rec{'mn'}\" id=\"mn\"><br><br></td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$aid_util::header_bg\">
<font color=\"#$aid_util::header_fg\"><big><strong class=\"hl\">2.
Graduating Class while at $ss</strong></big></font>
</td></tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"yr\"><strong>Graduation Year or Affiliation:</strong></label><br>
  <small>(such as 1993, 2001, or Teacher)</small></td>
  <td valign=\"top\">$star</td>
  <td valign=\"top\"><input type=\"text\" name=\"yr\" size=\"4\"
  value=\"$rec{'yr'}\" id=\"yr\"><br><br></td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$aid_util::header_bg\">
<font color=\"#$aid_util::header_fg\"><big><strong class=\"hl\">3.
Contact Info</strong></big></font>
</td></tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"e\"><strong>E-mail Address:</strong></label><br>
  <small>(such as chester\@aol.com)</small></td>
  <td valign=\"top\">$star</td>
  <td valign=\"top\"><input type=\"text\" name=\"e\" size=\"35\"
  value=\"\" id=\"e\"></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"w\"><strong>Personal Web Page:</strong></label></td>
  <td>&nbsp;</td>
  <td valign=\"top\"><input type=\"text\" name=\"w\" size=\"35\"
  value=\"$rec{'w'}\" id=\"w\"></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"l\"><strong>Location:</strong></label><br>
  <small>(your city, college, or company)</small></td>
  <td>&nbsp;</td>
  <td valign=\"top\"><input type=\"text\" name=\"l\" size=\"35\"
  value=\"$rec{'l'}\" id=\"l\"><br><br></td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$aid_util::header_bg\">
<font color=\"#$aid_util::header_fg\"><big><strong class=\"hl\">4.
What's New?</strong></big></font>
</td></tr>
<tr>
  <td colspan=\"3\">
  <label for=\"n\">
  Let your classmates know what you've been doing since<br>
  graduation, or any important bits of news you'd like to share.
  </label><br>
  <textarea name=\"n\" rows=\"10\" cols=\"55\" wrap=\"hard\"
  id=\"n\">$rec{'n'}</textarea><br><br>
  </td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$aid_util::header_bg\">
<font color=\"#$aid_util::header_fg\"><big><strong class=\"hl\">5.
E-mail Preferences</strong></big></font>
</td></tr>
<tr>
  <td colspan=\"3\"><input type=\"checkbox\"
  name=\"r\" id=\"r\" $reunion_chk><label
  for=\"r\">&nbsp;My class officers may notify me of
  reunion information via e-mail.</label><br><br>
  Would you like to <a target=\"c34286cd\"
  href=\"${mp}etc/faq.html#mailings\">receive
  a digest of the Directory every quarter</a><br>
  (at the beginning of February, May, August and November) via e-mail?<br>
";

    $body .= $reqradio[4];
    $body .= $reqradio[3];
    $body .= $reqradio[2] if $rec{'q'} == 2;
    $body .= $reqradio[1] if $rec{'q'} == 1;
    $body .= $reqradio[0];

    $body . "
  <input type=\"hidden\" name=\"id\" value=\"$rec{'id'}\">
  <input type=\"hidden\" name=\"c\" value=\"$rec{'c'}\">
  <input type=\"hidden\" name=\"eu\" value=\"$rec{'eu'}\">
  <input type=\"hidden\" name=\"lm\" value=\"$rec{'lm'}\">
  <input type=\"hidden\" name=\"a\" value=\"$rec{'a'}\">
  <input type=\"hidden\" name=\"iu\" value=\"$rec{'iu'}\">
  <input type=\"hidden\" name=\"v\" value=\"1\">
  <br><br>
  </td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$aid_util::header_bg\">
<font color=\"#$aid_util::header_fg\"><big><strong class=\"hl\">6.
Preview Listing</strong></big></font>
</td></tr>

<tr>
<td colspan=\"3\">
Please review the above information and click the
<strong>Preview&nbsp;Listing</strong> button to continue.
<br><input type=\"submit\"
value=\"Preview Listing\">
</td>
</tr>

</table>

</form>
";

}

1;

#
#     FILE: aid_submit.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: submission form for Alumni Internet Directory
#      $Id: aid_submit.pl,v 1.7 1999/05/31 18:26:09 mradwin Exp mradwin $
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

sub aid_submit_body
{
    package aid_util;

    local($[) = 0;
    local($_);
    local($body,$instr);
    local($star) = "<font color=\"#$star_fg\">*</font>";
    local(*rec_arg,$empty_fields) = @_;
    local(%rec) = &main'aid_html_entify_rec(*rec_arg); #'#
    local(@reqradio,$i,$reunion_chk,@empty_fields,$prev_email);

    $prev_email = defined $rec{'pe'} ? 
	$rec{'pe'} : $rec{'e'};
    $rec{'w'} = 'http://' if $rec{'w'} eq '';

    # give defaults if they're being revalidated
    if ($rec{'v'} == 0)
    {
	$rec{'q'} = $blank_entry{'q'};
	$rec{'r'} = $blank_entry{'r'};
    }

    for ($i = 0; $i <= $#req_descr_long; $i++) 
    {
	$reqradio[$i] = "
  &nbsp;&nbsp;&nbsp;&nbsp;<input type=\"radio\" name=\"q\" id=\"q$i\"
  value=\"$i\"" . (($rec{'q'} == $i) ? ' checked' : '') .
  " /><label for=\"q$i\">&nbsp;\n  $req_descr_long[$i]\n  </label><br />\n";
    }

    $reunion_chk = ($rec{'r'} == 1) ? ' checked' : '';

    $body = '';

    if ($empty_fields ne '')
    {
	if ($empty_fields =~ /e/ && $rec{'e'} !~ /^\s*$/)
	{
	    $body .= "<p><strong><span class=\"alert\">Your e-mail address\n";
	    $body .= "(<code>" . $rec{'e'} . "</code>)\n";
	    $body .= "appears to be invalid.</span>\n";
	    $body .= "<br />It must be in the form of ";
	    $body .= "<code>user\@isp.net</code>.\n";
	    if ($rec{'e'} !~ /\@/)
	    {
		$body .= "Perhaps you meant to type ";
		$body .= "<code>$rec{'e'}\@aol.com</code>?\n";
	    }
	    $body .= "</strong></p>\n\n";

	    $empty_fields =~ s/e//g;
	}

	@empty_fields = split(/\s+/, $empty_fields);
	if (@empty_fields)
	{
	    $body .= "<p class=\"alert\"><strong>It appears that\n";
	    $body .= "the following required fields were blank:";
	    $body .= "</strong></p>\n\n<ul>\n";

	    foreach(@empty_fields)
	    {
		$body .= "<li>" . $field_descr{$_} . "</li>\n";
	    }
	    $body .= "</ul>\n\n";
	}
    }

    $instr = "<p>Please " . (($rec{'id'} != -1) ? "update" : "enter") .
    " the following information about yourself.<br />
Fields marked with a $star
are required.  All other fields are optional.</p>
";

    $body .= "\n<form method=\"post\" action=\"" . $config{'submit_cgi'};
    $body .= "/$rec{'id'}" if $rec{'id'} != -1;
    $body .= "/new" if $rec{'id'} == -1;
    $body .= "\">\n\n" . $instr . "\n\n";
    
    $body .= "<table border=\"0\" cellspacing=\"7\">

<tr><td colspan=\"3\" bgcolor=\"#$header_bg\">
<font color=\"#$header_fg\"><strong><big>1.
Full Name</strong></big></font>
</td></tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"gn\"><strong>First Name:</strong></label></td>
  <td valign=\"top\">$star</td>
  <td valign=\"top\"><input type=\"text\" name=\"gn\" size=\"35\" 
  value=\"$rec{'gn'}\" id=\"gn\" /></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"mi\"><strong>Middle Initial:</strong></label></td>
  <td>&nbsp;</td>
  <td valign=\"top\"><input type=\"text\" name=\"mi\" size=\"1\" maxlength=\"1\"
  value=\"$rec{'mi'}\" id=\"mi\" /></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label 
  for=\"sn\"><strong>Last Name/Maiden Name:</strong></label><br />
  <small>(your last name in high school)</small></td>
  <td valign=\"top\">$star</td>
  <td valign=\"top\"><input type=\"text\" name=\"sn\" size=\"35\"
  value=\"$rec{'sn'}\" id=\"sn\" /></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"mn\"><strong>Married Last Name:</strong></label><br />
  <small>(if different from maiden name)</small></td>
  <td>&nbsp;</td>
  <td valign=\"top\"><input type=\"text\" name=\"mn\" size=\"35\"
  value=\"$rec{'mn'}\" id=\"mn\" /><br /><br /></td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$header_bg\">
<font color=\"#$header_fg\"><big><strong>2.
Graduating Class while at $config{'short_school'}</strong></big></font>
</td></tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"yr\"><strong>Graduation Year or Affiliation:</strong></label><br />
  <small>(such as 1993, 2001, or Teacher)</small></td>
  <td valign=\"top\">$star</td>
  <td valign=\"top\"><input type=\"text\" name=\"yr\" size=\"35\"
  value=\"$rec{'yr'}\" id=\"yr\" /><br /><br /></td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$header_bg\">
<font color=\"#$header_fg\"><big><strong>3.
Contact Info</strong></big></font>
</td></tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"e\"><strong>E-mail Address:</strong></label><br />
  <small>(such as chester\@aol.com)</small></td>
  <td valign=\"top\">$star</td>
  <td valign=\"top\"><input type=\"text\" name=\"e\" size=\"35\"
  value=\"$rec{'e'}\" id=\"e\" /></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"w\"><strong>Personal Web Page:</strong></label></td>
  <td>&nbsp;</td>
  <td valign=\"top\"><input type=\"text\" name=\"w\" size=\"35\"
  value=\"$rec{'w'}\" id=\"w\" /></td>
</tr>
<tr>
  <td valign=\"top\" align=\"right\"><label
  for=\"l\"><strong>Location:</strong></label><br />
  <small>(your city, college, or company)</small></td>
  <td>&nbsp;</td>
  <td valign=\"top\"><input type=\"text\" name=\"l\" size=\"35\"
  value=\"$rec{'l'}\" id=\"l\" /><br /><br /></td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$header_bg\">
<font color=\"#$header_fg\"><big><strong>4.
What's New?</strong></big></font>
</td></tr>
<tr>
  <td colspan=\"3\">
  <label for=\"n\">
  Let your classmates know what you've been doing since<br />
  graduation, or any important bits of news you'd like to share.
  </label><br />
  <textarea name=\"n\" rows=\"10\" cols=\"55\" wrap=\"hard\"
  id=\"n\">$rec{'n'}</textarea><br /><br />
  </td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$header_bg\">
<font color=\"#$header_fg\"><big><strong>5.
E-mail Preferences</strong></big></font>
</td></tr>
<tr>
  <td colspan=\"3\"><input type=\"checkbox\"
  name=\"r\" id=\"r\" $reunion_chk /><label
  for=\"r\">&nbsp;My class officers may notify me of
  reunion information via e-mail.</label><br /><br />
  Would you like to <a target=\"c34286cd\"
  href=\"$config{'master_path'}etc/faq.html#mailings\">receive
  a digest of the Directory every quarter</a><br />
  (at the beginning of February, May, August and November) via e-mail?<br />
";

    $body .= $reqradio[4];
    $body .= $reqradio[3];
    $body .= $reqradio[2] if $rec{'q'} == 2;
    $body .= $reqradio[1] if $rec{'q'} == 1;
    $body .= $reqradio[0];

    $body . "
  <input type=\"hidden\" name=\"id\" value=\"$rec{'id'}\" />
  <input type=\"hidden\" name=\"c\" value=\"$rec{'c'}\" />
  <input type=\"hidden\" name=\"eu\" value=\"$rec{'eu'}\" />
  <input type=\"hidden\" name=\"pe\" value=\"$prev_email\" />
  <input type=\"hidden\" name=\"v\" value=\"1\" />
  <br /><br />
  </td>
</tr>

<tr><td colspan=\"3\" bgcolor=\"#$header_bg\">
<font color=\"#$header_fg\"><big><strong>6.
Continue</strong></big></font>
</td></tr>

<tr>
<td colspan=\"3\">
Please review the above information and click the
<strong>Next&nbsp;&gt;</strong> button to continue.
<br /><input type=\"submit\" value=\"Next&nbsp;&gt;\" />
</td>
</tr>

</table>

</form>
";

}

# avoid stupid warnings
if ($^W && 0)
{
    &aid_submit_body();
    $aid_util'star_fg = '';
    $aid_util'field_descr = '';
}

1;

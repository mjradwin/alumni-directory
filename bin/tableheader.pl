#
#     FILE: tableheader.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: generates small-caps HTML headers with colored tables
#     DATE: Mon Nov 11 23:52:52 EST 1996
#      $Id: tableheader.pl,v 3.14 1999/03/26 19:43:18 mradwin Exp mradwin $
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


# parameters:
#  data     - text string           - text to display
#  size     - integer               - how much to increase font size by
#  color    - six-char rgb value    - background color of table
#  fontcolor- six-char rgb value    - foreground color of table
#  wide     - binary value (0 or 1) - should the table be full page width?
#  align    - align= html tag       - table alignment
#  valign   - valign= html tag      - table alignment
#  pretext  - string                - literal html code inserted before
#  posttext - string                - literal html code inserted after
#
sub tableheader {
    package tableheader;

    local($result,$fn_size,$bgcolor,$fgcolor,$width);
    local($data,$color,$wide,$align,$valign,
	  $pretext,$posttext) = @_;

    $bgcolor = "bgcolor=\"#$color\"";
    $width = " width=\"100%\"" if $wide;
    $align = "center" unless defined($align) && $align ne '';
    $valign = "middle" unless defined($valign) && $valign ne '';
    $pretext = '' unless defined($pretext) && $pretext ne '';
    $posttext = '' unless defined($posttext) && $posttext ne '';
   
    $result = &main'tableheader_internal($data,$fn_size,$fgcolor); #'

    return "
<!-- th start -->
<center>
<table cellspacing=0 cellpadding=1 border=0$width summary=\"$data\">
  <tr>
    <td bgcolor=\"#000000\" align=center>
    <table cellspacing=0 cellpadding=5 border=0 width=\"100%\" summary=\"\">
      <tr>
        <td $bgcolor align=$align valign=$valign>
        $pretext<strong>$result</strong>$posttext
        </td>
      </tr>
    </table>
    </td>
  </tr>
</table>
</center>
<!-- th end -->

";
}

sub tableheader_internal {
    package tableheader;

    local($data,$fn_size,$fgcolor) = @_;
    local($last,$result,@array);
    local($_);

    $fgcolor = "color=\"#$fgcolor\"";
    $fn_size = $fn_size; # ignore!

    @array = unpack('C*', $data);
    $last = pop(@array);   # the last char is a special case

    $result = "<font $fgcolor>"; 
   
    for (@array) {
	if ($_ == 32) {
	    $result .= "&nbsp; ";
	    next;

	} elsif (($_ >= 65 && $_ <= 90) || ($_ >= 48 && $_ <= 57)) {
	    $result .= sprintf("<big>%c</big>&nbsp;", $_);

	} elsif ($_ >= 97 && $_ <= 122) {
	    $result .= sprintf("%c", $_ - 32);
	    $result .= "&nbsp;";

	} elsif ($_ == 38) {
	    $result .= "&amp;";
	    $result .= "&nbsp;";

	} elsif ($_ == 60) {
	    $result .= "&lt;";
	    $result .= "&nbsp;";

	} elsif ($_ == 62) {
	    $result .= "&gt;";
	    $result .= "&nbsp;";

	} else {
	    $result .= sprintf("%c", $_);
	    $result .= "&nbsp;";
	}
    }

    # handle the last char differently
    if (($last >= 65 && $last <= 90) || ($last >= 48 && $last <= 57)) {
	$result .= sprintf("<big>%c</big>", $last);
    } elsif ($last >= 97 && $last <= 122) {
	$result .= sprintf("%c", $last - 32);
    } elsif ($last == 38) {
	$result .= "&amp;";
    } elsif ($last == 60) {
	$result .= "&lt;";
    } elsif ($last == 62) {
	$result .= "&gt;";
    } else {
	$result .= sprintf("%c", $last);
    }

    $result .= "</font>";
    $result;
}

1;

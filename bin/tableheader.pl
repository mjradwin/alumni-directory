#
#     FILE: tableheader.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: generates small-caps HTML headers with colored tables
#     DATE: Mon Nov 11 23:52:52 EST 1996
#      $Id: tableheader.pl,v 3.11 1998/12/28 17:16:49 mradwin Exp mradwin $
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
    local($data,$size,$color,$fontcolor,$wide,$align,$valign,
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
    $fn_size = "size=\"+$fn_size\"";

    @array = unpack('C*', $data);
    $last = pop(@array);   # the last char is a special case

    $result = ""; 
   
    for (@array) {
	if ($_ == 32) {
	    $result .= "&nbsp; ";
	    next;

	} elsif (($_ >= 65 && $_ <= 90) || ($_ >= 48 && $_ <= 57)) {
	    $result .= sprintf("<font %s %s>%c</font>&nbsp;", $fn_size, 
			       $fgcolor, $_);

	} elsif ($_ >= 97 && $_ <= 122) {
	    $result .= sprintf("<font %s>%c</font>", $fgcolor, $_ - 32);
	    $result .= "&nbsp;";

	} elsif ($_ == 38) {
	    $result .= sprintf("<font %s>&amp;</font>", $fgcolor);
	    $result .= "&nbsp;";

	} elsif ($_ == 60) {
	    $result .= sprintf("<font %s>&lt;</font>", $fgcolor);
	    $result .= "&nbsp;";

	} elsif ($_ == 62) {
	    $result .= sprintf("<font %s>&gt;</font>", $fgcolor);
	    $result .= "&nbsp;";

	} else {
	    $result .= sprintf("<font %s>%c</font>", $fgcolor, $_);
	    $result .= "&nbsp;";
	}
    }

    # handle the last char differently
	
    if (($last >= 65 && $last <= 90) || ($last >= 48 && $last <= 57)) {
	$result .= sprintf("<font %s %s>%c</font>", $fn_size, 
			   $fgcolor, $last);
    } elsif ($last >= 97 && $last <= 122) {
	$result .= sprintf("<font %s>%c</font>", $fgcolor, $last - 32);
    } else {
	$result .= sprintf("<font %s>%c</font>", $fgcolor, $last);
    }

    $result;
}
1;

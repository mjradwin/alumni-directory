#
#     FILE: tableheader.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: generates small-caps HTML headers with colored tables
#     DATE: Mon Nov 11 23:52:52 EST 1996
#      $Id: tableheader.pl,v 1.3 1997/03/23 20:56:39 mjr Exp mjr $
#


# parameters:
#  data     - text string           - text to display
#  size     - integer               - how much to increase font size by
#  color    - six-char rgb value    - background color of table
#  wide     - binary value (0 or 1) - should the table be full page width?
#  align    - align= html tag       - table alignment
#  valign   - valign= html tag      - table alignment
#  pretext  - string                - literal html code inserted before
#  posttext - string                - literal html code inserted after
#
sub tableheader {
    package tableheader;

    local($[) = 0;
    local($_);
    local($last,$result,$fn_size,$bgcolor,$width);
    local($data,$size,$color,$wide,$align,$valign,$pretext,$posttext) = @_;

    @array = unpack('C*', $data);
    $last = pop(@array);   # the last char is a special case

    $result = ""; 
    $bgcolor = "bgcolor=\"#$color\"";
    $fn_size = "size=\"+$size\"";
    $width = " width=\"100%\"" if $wide;
    $align = "center" if $align eq '';
    $valign = "middle" if $valign eq '';
   
    for (@array) {
	if ($_ == 32) {
	    $result .= "&nbsp; ";
	    next;
	} elsif ($_ >= 65 && $_ <= 90) {
	    $result .= sprintf("<font %s>%c</font>&nbsp;", $fn_size, $_);
	} elsif ($_ >= 97 && $_ <= 122) {
	    $result .= sprintf("%c", $_ - 32);
	    $result .= "&nbsp;";
	} else {
	    $result .= sprintf("%c", $_);
	    $result .= "&nbsp;";
	}
    }

    # handle the last char differently
    if ($last >= 65 && $last <= 90) {
	$result .= sprintf("<font %s>%c</font>", $fn_size, $last);
    } elsif ($last >= 97 && $last <= 122) {
	$result .= sprintf("%c", $last - 32);
    } else {
	$result .= sprintf("%c", $last);
    }

    return "
<!-- tableheader start \"$data\" -->
<center>
<table cellspacing=0 cellpadding=1 border=0$width>
  <tr>
    <td bgcolor=\"#000000\" align=center>
    <table cellspacing=0 cellpadding=5 border=0 width=\"100%\">
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
<!-- tableheader end \"$data\" -->

";
}

1;

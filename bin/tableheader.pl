#
#     FILE: tableheader.pl
#   AUTHOR: Michael J. Radwin
#    DESCR: generates small-caps HTML headers with colored tables
#     DATE: Mon Nov 11 23:52:52 EST 1996
#      $Id: tableheader.pl,v 1.2 1996/11/12 04:53:40 mjr Exp mjr $
#


# data is a text string
# size is an integer
# color is a six-char rgb value
# wide is a binary value (0 or 1)
sub tableheader {
    package tableheader;

    local($[) = 0;
    local($_);
    local($last, $result, $fn_size, $bgcolor, $width);
    local($data, $size, $color, $wide) = @_;

    @array = unpack('C*', $data);
    $last = pop(@array);   # the last char is a special case

    $result = ""; 
    $bgcolor = "bgcolor=\"#$color\"";
    $fn_size = "size=\"+$size\"";
    $width = " width=\"100%\"" if $wide;
   
    for (@array) {
	if ($_ == 32) {
	    $result .= "&nbsp; ";
	    next;
	} elsif ($_ >= 65 && $_ <= 90) {
	    $result .= sprintf("<font %s>%c</font>&nbsp;", $fn_size, $_);
	} else {
	    $result .= uc(sprintf("%c", $_));
	    $result .= "&nbsp;";
	}
    }

    # handle the last char differently
    if ($last >= 65 && $last <= 90) {
	$result .= sprintf("<font %s>%c</font>", $fn_size, $last);
    } else {
	$result .= uc(sprintf("%c", $last));
    }

    return "
<table cellspacing=0 cellpadding=1 border=0$width>
  <tr>
    <td bgcolor=\"#000000\" align=center>
    <table cellspacing=0 cellpadding=5 border=0 width=\"100%\">
      <tr>
        <td $bgcolor align=center valign=middle>
        <strong>$result</strong>
        </td>
      </tr>
    </table>
    </td>
  </tr>
</table>

";
}

1;

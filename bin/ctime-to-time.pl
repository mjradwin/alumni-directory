#!/usr/local/bin/perl -w

# Thu Mar 19 21:18:14 1998

require 'timelocal.pl';
require 'ctime.pl';

$wday = $yday = $isdst = '';

%months =
    ('Jan', '0',
     'Feb', '1',
     'Mar', '2',
     'Apr', '3',
     'May', '4',
     'Jun', '5',
     'Jul', '6',
     'Aug', '7',
     'Sep', '8',
     'Oct', '9',
     'Nov','10',
     'Dec','11');

$prevtime = 0;

while(<>)
{
    chop;

    s/^\[([^\]]+)\](.*)/$1/;
    $rest = $2;

    $mon = substr($_, 4, 3);
    $mday = substr($_, 8, 2);
    $hour = substr($_, 11, 2);
    $min = substr($_, 14, 2);
    $sec = substr($_, 17, 2);
    $year = substr($_, 20, 4);

    $mon = $months{$mon};
    $year -= 1900;

    $time = &timelocal($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);

    if ($time != $prevtime)
    {
	$prevtime = $time;
	$date = &ctime($time);
	chop $date;
	print "# [$date]\n";
    }

    print $time, $rest, "\n";
}

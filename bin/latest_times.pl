#!/usr/local/bin/perl -w

%a = ();
while(<>)
{
    next if /^\#/;

    if (/^(\d+) - (\d+)/)
    {
	if (defined $a{$2})
	{
	    $a{$2} = $1 if $1 > $a{$2};
	}
	else
	{
	    $a{$2} = $1;
	}
    }
}

open(DATA,"data/master.u") || die;
while(<DATA>)
{
    next unless /&id=(\d+)&/;
    chop;
    print $_;
    print "&lm=$a{$1}" if defined $a{$1};
    print "&lm=0" unless defined $a{$1};
    print "\n";
}
close(DATA);


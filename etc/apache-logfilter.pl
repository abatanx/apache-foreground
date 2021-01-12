#!/usr/bin/perl

#--------------------------
# Apache stdout log filter
#--------------------------
sub r
{
	my($s) = @_;
	if( $s =~ /x([0-9a-f]{2})/ ) { chr(hex($1)); }
	elsif( $s eq 'n' ) { chr(13);chr(10); }
	elsif( $s eq 't' ) { chr(9); }
	else { '' };
}

while(<>)
{
	s/\\r\\n/\\n/g;
	s/\\r/\\n/g;
	s/^\[.+?\] \[.+?\] \[.+?\] \[.+?\] //;
	s/\\([tn]|x[0-9a-f]{2})/r($1)/ge;
	print $_;
}

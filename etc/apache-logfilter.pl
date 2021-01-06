#!/usr/bin/perl

#--------------------------
# Apache stdout log filter
#--------------------------
sub r
{
	my($s) = @_;
	if( $s =~ /x([0-9a-f]{2})/ ) { chr(hex($1)); }
	elsif( $s eq 't' ) { chr(9);  }
	elsif( $s eq 'r' ) { chr(10); }
	elsif( $s eq 'n' ) { chr(13); }
	else { '' };
}

while(<>)
{
	s/^\[.+?\] \[.+?\] \[.+?\] \[.+?\] //;
	s/\\([trn]|x[0-9a-f]{2})/r($1)/ge;
	print $_;
}

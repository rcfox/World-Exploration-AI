package Utility;
use base 'Exporter';
our @EXPORT = (qw(random_int_between rgb2c c2rgb));

sub random_int_between
{
	my($min, $max) = @_;
	# Assumes that the two arguments are integers themselves!
	return $min if $min == $max;
	($min, $max) = ($max, $min)  if  $min > $max;
	return $min + int rand(1 + $max - $min);
}

# Convert R,G,B to 0xRRGGBB
sub rgb2c
{
	my ($r,$g,$b) = @_;
	return ($r << 16) | ($g << 8) | $b;
}

# Convert 0xRRGGBB to R,G,B
sub c2rgb
{
	my $colour = shift;
	return ( (($colour >> 16)&0xFF), (($colour >> 8)&0xFF), ($colour&0xFF) );
}

1;

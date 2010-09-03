package Utility;
use base 'Exporter';
our @EXPORT = ('random_int_between');

sub random_int_between
{
	my($min, $max) = @_;
	# Assumes that the two arguments are integers themselves!
	return $min if $min == $max;
	($min, $max) = ($max, $min)  if  $min > $max;
	return $min + int rand(1 + $max - $min);
}

1;

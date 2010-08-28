package Positionable;
use Moose::Role;

has 'x' => (isa => 'Int', is => 'rw');
has 'y' => (isa => 'Int', is => 'rw');

sub place
{
	my $self = shift;
	my ($x,$y) = @_;

	$self->x($x);
	$self->y($y);
}

1;

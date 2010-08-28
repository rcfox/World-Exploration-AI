package World::Feature;
use Moose;

with 'Positionable', 'Drawable';

has 'char' => (isa => 'Str', is => 'ro');

has 'solid' => ( isa => 'Bool', is => 'ro', default => 0 );
has 'opaque' => ( isa => 'Bool', is => 'ro', default => 0 );

has 'on_touch' => ( isa => 'CodeRef', is => 'ro', default => sub{sub{1}} );

# Need to override these if a child class has more complex data.
sub clone
{
	my $self = shift;
	bless { %$self }, ref $self;
}

sub compare
{
	my $self = shift;
	my $other = shift;

	return 0 if $self->char ne $other->char;
	return 0 if $self->solid != $other->solid;
	return 0 if $self->opaque != $other->opaque;

	return 1;
}

1;

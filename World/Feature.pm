package World::Feature;
use Moose;

has 'char' => (isa => 'Str', is => 'ro');

has 'solid' => ( isa => 'Bool', is => 'ro', default => 0 );
has 'opaque' => ( isa => 'Bool', is => 'ro', default => 0 );

has 'on_touch' => ( isa => 'CodeRef', is => 'ro', default => sub{sub{1}} );

has 'x' => (isa => 'Int', is => 'rw');
has 'y' => (isa => 'Int', is => 'rw');

# Need to override this if a child class has more complex data.
sub clone
{
	my $self = shift;
	bless { %$self }, ref $self;
}

1;

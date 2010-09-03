package World::Room;
use Moose;
use World::Feature;
use Utility;

has 'height' =>
    (
	    isa => 'Int',
	    is => 'ro',
	);

has 'width' =>
    (
	    isa => 'Int',
	    is => 'ro',
	);

has 'map_legend' =>
    (
	    isa => 'HashRef[World::Feature]',
	    is => 'rw',
	    default => sub{{}},
	);

has 'map' =>
    (
	    isa => 'ArrayRef[ArrayRef[World::Feature]]',
	    is => 'rw',
	);

has 'entities' =>
    (
	    isa => 'ArrayRef[World::Entity]',
	    is => 'rw',
	    default => sub{[]},
	);

sub from_string
{
	my $self = shift;
	my $string = shift;
	my @rows = split(/\n/,$string);
	my @map;
	for(my $y = 0; $y < @rows; ++$y)
	{
		my @row;
		my @row_split = split(//,$rows[$y]);
		for(my $x = 0; $x < @row_split; ++$x)
		{
			my $clone = $self->map_legend->{$row_split[$x]}->clone();
			$clone->place($x,$y);
			push @row, $clone;
		}
		push @map, \@row;
	}
	$self->{height} = scalar @rows;
	$self->{width} = length $rows[0];
	$self->map(\@map);
	return $self;
}

sub draw
{
	my $self = shift;
	for (my $y = 0; $y < $self->height; ++$y)
	{
		for(my $x = 0; $x < $self->width; ++$x)
		{
			print $self->map->[$y]->[$x]->char;
		}
		print "\n";
	}
}

sub update
{
	my $self = shift;
	for (my $y = 0; $y < $self->height; ++$y)
	{
		for(my $x = 0; $x < $self->width; ++$x)
		{
			$self->map->[$y]->[$x]->draw();;
		}
	}

	my @entities = @{$self->entities};
	foreach (@entities)
	{
		$_->draw();
	}
}

sub add_entity
{
	my $self = shift;
	my $entity = shift;

	push @{$self->entities},$entity;
}

sub add_feature
{
	my $self = shift;
	my $feature = shift;

	$self->map_legend->{$feature->char} = $feature;
}

sub check_solid
{
	my $self = shift;
	my ($x,$y) = @_;
	return 1 if ($x < 0 || $x >= $self->width);
	return 1 if ($y < 0 || $y >= $self->height);
	
	return $self->map->[$y]->[$x]->solid;
}

sub check_opaque
{
	my $self = shift;
	my ($x,$y) = @_;
	return 1 if ($x < 0 || $x >= $self->width);
	return 1 if ($y < 0 || $y >= $self->height);
	
	return $self->map->[$y]->[$x]->opaque;
}

sub check_bounds
{
	my $self = shift;
	my ($x,$y) = @_;
	return ($x >= 0 && $y >= 0 && $x < $self->width && $y < $self->height);
}

sub random_free_coordinates
{
	my $self = shift;
	my ($x,$y);
	do
	{
		$x = random_int_between(0,$self->width);
		$y = random_int_between(0,$self->height);
	} while ($self->check_solid($x,$y));
	return ($x,$y);
}

1;

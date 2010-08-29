package World::Entity;
use Moose;

with 'Positionable', 'Drawable';

has 'facing' => (isa => 'Num', is => 'rw', default => 0);

has 'sight_range' => (isa => 'Int', is => 'rw', default => 5);

has 'name' => (isa => 'Str', is => 'rw');

has 'room' => (isa => 'World::Room', is => 'rw');

has 'map_memory' =>
    (
	    isa => 'ArrayRef[ArrayRef[World::Feature]]',
	    is => 'rw',
	    lazy => 1,
	    default => sub
	    {
		    my $self = shift;
		    my @map;
		    my $nothing = World::Feature->new(char=>' ',surface=>$self->surface,gfx_color=>0);
		    for(my $y = 0; $y < $self->room->height; ++$y)
		    {
			    my @row;
			    for (my $x = 0; $x < $self->room->width; ++$x)
			    {
				    $nothing->place($x,$y);
				    push @row, $nothing;
			    }
			    push @map, \@row;
		    }
		    return \@map
	    },
	);

sub move
{
	my $self = shift;
	my ($dx,$dy) = @_;
	my ($nx,$ny) = ($self->x+$dx,$self->y+$dy);

	if ($self->room->check_solid($nx,$ny) == 0)
	{
		$self->place($nx,$ny);
		$self->facing(atan2($dy,$dx)*180/3.14159);
		return 1;
	}

	return 0;
}

sub learn_map
{
	my $self = shift;
	my @map = @{$self->fov};

	for(my $y = $self->y-($self->sight_range-1); $y < $self->y+($self->sight_range-1); ++$y)
	{
		for(my $x = $self->x-($self->sight_range-1); $x < $self->x+($self->sight_range-1); ++$x)
		{
			my $ty = $y - ($self->y-$self->sight_range);
			my $tx = $x - ($self->x-$self->sight_range);

			if ($x >= 0 && $y >= 0 && $map[$tx][$ty])
			{
				my $memory = $self->map_memory->[$y]->[$x];
				my $actual = $self->room->map->[$y]->[$x];

				if (!$memory->compare($actual))
				{
					$self->map_memory->[$y]->[$x] = $actual->clone;
				}
			}
		}
	}
}

sub remember_map
{
	my $self = shift;
	for(my $y = 0; $y < $self->room->height; ++$y)
	{
		for(my $x = 0; $x < $self->room->width; ++$x)
		{
			if ($x == $self->x && $y == $self->y)
			{
				print "@";
			}
			else
			{
				print $self->map_memory->[$y]->[$x]->char;
			}
		}
		print "\n";
	}
}

sub look
{
	my $self = shift;
	my @map = @{$self->fov};

	for(my $y = 0; $y < $self->room->height; ++$y)
	{
		for(my $x = 0; $x < $self->room->width; ++$x)
		{
			if ($x == $self->x && $y == $self->y)
			{
				print "@";
			}
			else
			{
				my $tx = $x-$self->x+$self->sight_range;
				my $ty = $y-$self->y+$self->sight_range;
				if ($tx > 0 && $ty > 0 && $map[$tx][$ty])
				{
					print $self->room->map->[$y]->[$x]->char;
				}
				else
				{
					print " ";
				}
			}
		}
		print "\n";
	}	
}

sub fov
{
	my $self = shift;
	my $map = [];
	for(my $y = 0; $y < 2*$self->sight_range-1; ++$y)
	{
		for(my $x = 0; $x < 2*$self->sight_range-1; ++$x)
		{
			$map->[$x][$y] = 0;
		}
	}
	
	for(my $i = 0; $i < 360; $i += 1)
	{
		my $x = cos($i*0.01745);
		my $y = sin($i*0.01745);
		$map = $self->cast_ray($map,$x,$y);
	}
	return $map;
}

sub cast_ray
{
	my $self = shift;
	my $map = shift;
	my ($x,$y) = @_;
	my ($px,$py) = ($self->x, $self->y);
	my ($ox,$oy) = (0,0);

	for(my $i = 0; $i < $self->sight_range; ++$i)
	{
		# Perl's method for rounding isn't the most intuitive...
		my $rx = int(sprintf("%.0f",$ox));
		my $ry = int(sprintf("%.0f",$oy));

		$map->[$rx+$self->sight_range][$ry+$self->sight_range] = 1;

		# Extend the ray
		$ox += $x;
		$oy += $y;
		last if($self->room->check_opaque($px+$rx,$py+$ry) && ($rx != 0|| $ry != 0));
	}

	return $map;
}

sub update
{
	my $self = shift;
	for (my $y = 0; $y < $self->room->height; ++$y)
	{
		for(my $x = 0; $x < $self->room->width; ++$x)
		{
			$self->map_memory->[$y]->[$x]->draw();
		}
	}

	my @entities = @{$self->room->entities};
	my $nothing = World::Feature->new(char=>' ',surface=>$self->surface,gfx_color=>0);
	foreach (@entities)
	{
		my ($x,$y) = ($_->x,$_->y);
		if (!$self->map_memory->[$y]->[$x]->compare($nothing))
		{
			$_->draw();
		}
	}
}

1;

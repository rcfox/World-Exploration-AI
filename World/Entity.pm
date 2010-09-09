package World::Entity;
use Moose;
use Utility;

with 'Positionable', 'Drawable', 'Controllable';

has 'facing' => (isa => 'Num', is => 'rw', default => 0);

has 'sight_range' => (isa => 'Int', is => 'rw', default => 7);
has 'sight_angle' => (isa => 'Int', is => 'rw', default => 120);

has 'name' => (isa => 'Str', is => 'rw');

has 'room' => (isa => 'World::Room', is => 'rw');

has 'seen_entities' =>
    (
	    isa => 'ArrayRef[World::Entity]',
	    is => 'rw',
	    default => sub{[]},
	);

has 'seen_items' =>
    (
	    isa => 'ArrayRef[World::Item]',
	    is => 'rw',
	    default => sub{[]},
	);

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

	$self->facing(atan2($dy,$dx)*180/3.14159);
	if ($self->room->check_solid($nx,$ny) == 0)
	{
		$self->place($nx,$ny);		
		return 1;
	}

	return 0;
}

sub learn_map
{
	my $self = shift;
	my @map = @{$self->fov};
	my $sight = $self->sight_range;
	my $room = $self->room;

	my $sx = $self->x;
	my $sy = $self->y;

	my @entities = grep
	{
		my $ty = $_->y - ($sy-$sight);
		my $tx = $_->x - ($sx-$sight);
		my $return = 0;
		if($tx >= 0 && $tx < @map && $ty >= 0 && $ty < @{$map[$tx]})
		{
			$return = $map[$tx][$ty];
		}
		$return;
	} @{$room->entities};
	$self->seen_entities(\@entities);

	my @items = grep
	{
		my $ty = $_->y - ($sy-$sight);
		my $tx = $_->x - ($sx-$sight);
		my $return = 0;
		if($tx >= 0 && $tx < @map && $ty >= 0 && $ty < @{$map[$tx]})
		{
			$return = $map[$tx][$ty];
		}
		$return;
	} @{$room->items};
	$self->seen_items(\@items);

	for(my $y = $sy-($sight-1); $y < $sy+($sight-1); ++$y)
	{
		for(my $x = $sx-($sight-1); $x < $sx+($sight-1); ++$x)
		{
			my $ty = $y - ($sy-$sight);
			my $tx = $x - ($sx-$sight);

			if ($room->check_bounds($x,$y) && $map[$tx][$ty])
			{
				my $memory = $self->map_memory->[$y]->[$x];
				my $actual = $room->map->[$y]->[$x];

				if (!$memory->compare($actual))
				{
					$self->map_memory->[$y]->[$x] = $actual->clone;
				}

				# Used by child classes to do anything extra with the map memory, like
				# storing a passability map for A*.
				$self->manage_map_memory($x,$y);
			}
		}
	}
}

sub manage_map_memory
{

}

sub look
{
	my $self = shift;
	my @map = @{$self->fov};

	my $map_memory = $self->map_memory;
	my $sight = $self->sight_range;
	my $surface = $self->surface;

	my $room_map = $self->room->map;
	my $room_width = $self->room->width;
	my $room_height = $self->room->height;

	my $sx = $self->x;
	my $sy = $self->y;

	my $rect = SDL::Rect->new(0,0,16,16);
	my $color = 0;
	for(my $y = 0; $y < $room_height; ++$y)
	{
		for(my $x = 0; $x < $room_width; ++$x)
		{
			$rect->x($x*16);
			$rect->y($y*16);

			my $tx = $x-$sx+$sight;
			my $ty = $y-$sy+$sight;
			if ($tx >= 0 && $ty >= 0 && $map[$tx][$ty])
			{
				$color = $room_map->[$y]->[$x]->gfx_color;
			}
			else
			{
				my $c = $map_memory->[$y]->[$x]->gfx_color;
				my ($r,$g,$b) = c2rgb($c);
				$color = rgb2c($r/2,$g/2,$b/2);

			}
			$surface->draw_rect($rect,$color);
		}		
	}
	foreach (@{$self->seen_entities})
	{
		$_->draw();
	}
	foreach (@{$self->seen_items})
	{
		$_->draw();
	}
}

sub fov
{
	my $self = shift;
	my $map = [];
	my $sight = $self->sight_range;
	
	for(my $y = 0; $y < 2*$sight-1; ++$y)
	{
		for(my $x = 0; $x < 2*$sight-1; ++$x)
		{
			$map->[$x][$y] = 0;
		}
	}
	
	for(my $i = -$self->sight_angle/2 + $self->facing; $i <= $self->sight_angle/2 + $self->facing; $i += 5)
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
	my $sight = $self->sight_range;

	for(my $i = 0; $i < $sight; ++$i)
	{
		# Perl's method for rounding isn't the most intuitive...
		my $rx = int(sprintf("%.0f",$ox));
		my $ry = int(sprintf("%.0f",$oy));

		$map->[$rx+$sight][$ry+$sight] = 1;

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
	foreach (@{$self->seen_entities})
	{
		$_->draw();
	}
}

1;

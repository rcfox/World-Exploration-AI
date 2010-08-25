package World::Entity;
use Moose;

has 'x' => (isa => 'Int', is => 'rw');
has 'y' => (isa => 'Int', is => 'rw');
has 'facing' => (isa => 'Num', is => 'rw', default => 0);

has 'sight_range' => (isa => 'Int', is => 'rw', default => 10);

has 'name' => (isa => 'Str', is => 'rw');

has 'room' => (isa => 'World::Room', is => 'rw');

sub move
{
	my $self = shift;
	my ($dx,$dy) = @_;
	my ($nx,$ny) = ($self->x+$dx,$self->y+$dy);

	if ($self->room->check_solid($nx,$ny) == 0)
	{
		$self->x($nx);
		$self->y($ny);
		return 1;
	}

	return 0;
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
	
	# for(my $y = 0; $y < @map; ++$y)
	# {
	# 	for(my $x = 0; $x < @{$map[0]}; ++$x)
	# 	{
	# 		print $map[$x][$y];
	# 	}
	# 	print "\n";
	# }
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

	for(my $i = 0 ; $i < 360; $i += 1)
#	my $i = 0;
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
		my $rx = int(sprintf("%.0f",$ox));
		my $ry = int(sprintf("%.0f",$oy));

		$map->[$rx+$self->sight_range][$ry+$self->sight_range] = 1;
		if($self->room->check_opaque($px+$rx,$py+$ry) && ($rx != 0 || $ry != 0))
		{
			return $map;
		}
		my $c = $self->room->check_opaque($px+$rx,$py+$ry);
		my $b = ($rx ? 1 : 0);
		my $d = ($ry ? 1 : 0);
		
		$ox += $x;
		$oy += $y;
	}

	return $map;
}

1;

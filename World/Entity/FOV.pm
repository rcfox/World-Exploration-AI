package World::Entity::FOV;
use Memoize;
use Storable qw(dclone);

sub check_fov
{
	my $sight_range = shift;
	my $sight_angle = shift;
	my $facing = shift;
	my $entity = shift;
	my @map = ();

	my $room = $entity->room;
	my ($ex,$ey) = ($entity->x,$entity->y);
	
	for(my $y = 0; $y < 2*$sight_range-1; ++$y)
	{
		for(my $x = 0; $x < 2*$sight_range-1; ++$x)
		{
			$map[$x][$y] = 0;
		}
	}

	my $start = "$sight_range,$sight_range";
	
	my $tree = dclone(fov($sight_range,$sight_angle,$facing));

	$map[$sight_range][$sight_range] = 1;
	foreach(keys %{$tree->{$start}{child}})
	{
		update_fov_map(\@map,$tree,$_,$room,$sight_range,$entity->x,$entity->y);
	}
	
	# for my $k (keys %tree)
	# {
	# 	my ($x,$y) = ($tree{$k}{x},$tree{$k}{y});		
	# 	my ($tx,$ty) = ($entity->x+$x-$sight_range,$entity->y+$y-$sight_range);
	# 	$map[$x][$y] = 1;
	# 	last if($room->check_opaque($tx,$ty));
	# }
	
	return \@map;
}

sub update_fov_map
{
	my $map = shift;
	my $tree = shift;
	my $coord = shift;
	my $room = shift;
	my $sight_range = shift;
	my ($ex,$ey) = @_;
	my ($x,$y) = ($tree->{$coord}{x},$tree->{$coord}{y});
	my ($tx,$ty) = ($ex+$x-$sight_range,$ey+$y-$sight_range);

	$map->[$x][$y] = 1;

	if ($room->check_opaque($tx,$ty))
	{
		$tree->{$coord}{child} = {};		
	}
	else
	{
		foreach(keys %{$tree->{$coord}{child}})
		{
			update_fov_map($map,$tree,$_,$room,$sight_range,$ex,$ey);
		}
	}
}

#memoize('fov');
sub fov
{
	my $sight_range = shift;
	my $sight_angle = shift;
	my $facing = shift;
	my %tree = ();
		
	for(my $i = -$sight_angle/2 + $facing; $i <= $sight_angle/2 + $facing; $i += 5)
	{
		my $x = cos($i*0.01745);
		my $y = sin($i*0.01745);
		cast_ray(\%tree,$sight_range,$x,$y);
	}

	foreach(keys %tree)
	{
		my ($x,$y) = split /,/, $_;
		$tree{$_}{x} = $x;
		$tree{$_}{y} = $y;
	}

	return \%tree;
}

sub cast_ray
{
	my $tree = shift;
	my $sight_range = shift;
	my ($x,$y) = @_;
	my ($ox,$oy) = (0,0);

	my ($lx,$ly);

	for(my $i = 0; $i < $sight_range; ++$i)
	{
		# Perl's method for rounding isn't the most intuitive...
		my $rx = int(sprintf("%.0f",$ox));
		my $ry = int(sprintf("%.0f",$oy));

		if(!$map->[$rx+$sight_range][$ry+$sight_range])
		{
			my ($ax,$ay) = ($rx+$sight_range,$ry+$sight_range);
			$tree->{"$lx,$ly"}{child}{"$ax,$ay"} = 1 if ($lx && $ly && !($lx == $ax && $ly == $ay));
			$tree->{"$ax,$ay"} = {} if(!$tree->{"$ax,$ay"});
			($lx,$ly) = ($ax,$ay);
		}	   		

		# Extend the ray
		$ox += $x;
		$oy += $y;
	}
}

1;

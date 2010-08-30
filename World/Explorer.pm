package World::Explorer;
use Moose;

use AI::Pathfinding::AStar::Rectangle;

extends 'World::Entity';

has 'passability_map' =>
    (
        is => 'rw',
        isa => 'Any',
        lazy => 1,
        default => sub
        {
            my $room = shift()->room;
            my $p = AI::Pathfinding::AStar::Rectangle->new({width=>$room->width, height=>$room->width});
            $p->foreach_xy_set(sub{1});
            $p;
        },
    );

has 'destination_x' =>
    (
	    is => 'rw',
	    isa => 'Int',
	    default => -1,
	);

has 'destination_y' =>
    (
	    is => 'rw',
	    isa => 'Int',
	    default => -1,
	);

has 'path' =>
    (
	    is => 'rw',
	    isa => 'ArrayRef[Int]',
	    default => sub{[]},
	);

override 'manage_map_memory' => sub
{
	my $self = shift;
	my ($x,$y) = @_;
	$self->passability_map->set_passability($x,$y,!$self->room->check_solid($x,$y));
	$self->passability_map->set_passability($x,$y,1) if ($self->x == $x && $self->y == $y);
};

sub move_to
{
	my $self = shift;
	my ($x,$y) = @_;

	return 0 if ($self->x == $x && $self->y == $y);

	if (!$self->passability_map->is_path_valid($self->x,$self->y,$self->path) || $x != $self->destination_x || $y != $self->destination_y)
	{
		$self->destination_x($x);
		$self->destination_y($y);
		my @path = split(//,$self->passability_map->astar($self->x,$self->y,$x,$y));
		$self->path(\@path);
	}

	my $dir = shift @{$self->path};
	my $moved;
	if ($dir)
    {
        $moved = $self->move(-1,1)  if ($dir == 1);
        $moved = $self->move(0,1)   if ($dir == 2);
        $moved = $self->move(1,1)   if ($dir == 3);
        $moved = $self->move(-1,0)  if ($dir == 4);
        $moved = $self->move(1,0)   if ($dir == 6);
        $moved = $self->move(-1,-1) if ($dir == 7);
        $moved = $self->move(0,-1)  if ($dir == 8);
        $moved = $self->move(1,-1)  if ($dir == 9);
    }
	return $moved;
}

sub print_passability
{
	my $self = shift;
	for(my $y = 0; $y < $self->room->height; ++$y)
	{
		for(my $x = 0; $x < $self->room->width; ++$x)
		{
			print $self->passability_map->get_passability($x,$y);
		}
		print "\n";
	}
}


1;

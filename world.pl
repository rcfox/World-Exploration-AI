#!/usr/bin/perl
use strict;
use warnings;
use 5.010;
use Term::ANSIScreen qw(cls);
use Time::HiRes qw(usleep);

use World::Room;
use World::Feature;
use World::Entity;

my $room = World::Room->new();
$room->add_feature(World::Feature->new(char=>'.'));
$room->add_feature(World::Feature->new(char=>'#',solid=>1,opaque=>1));
$room->add_feature(World::Feature->new(char=>'|',solid=>1,opaque=>1));
$room->add_feature(World::Feature->new(char=>'+'));
$room->add_feature(World::Feature->new(char=>'%',solid=>1));
$room->add_feature(World::Feature->new(char=>'~',opaque=>1));

$room->from_string(<<MAP);
############################
#..........................#
#..........................#
#..........................#
#..........................#
#..........................#
#..........................#
#..........................#
#..........................#
#..........................#
#............#.............#
#.............#............#
#..............#...........#
#..............##..........#
#...............##.........#
#................##........#
#.................##.......#
#.......#############......#
#..........................#
#..........................#
############################
MAP

$room->draw();

my $guy = World::Entity->new(x=>9, y=>11, name=>"Guy",room=>$room);

while(1)
{
	print cls();
	$guy->move(random_int_between(-1,1),random_int_between(-1,1));
	$guy->look();
	usleep(300000);
}

sub random_int_between {
	my($min, $max) = @_;
	# Assumes that the two arguments are integers themselves!
	return $min if $min == $max;
	($min, $max) = ($max, $min)  if  $min > $max;
	return $min + int rand(1 + $max - $min);
}

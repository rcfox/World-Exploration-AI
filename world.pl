#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

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
.##...........#........
##....~~~.....|........
#.....~~~.....%........
##....~~~.....+........
.##...........%........
.##...........%........
.##...........%........
.##...........%........
.##...........%........
.##...........%........
.##...........%........
.##...........%........
MAP

$room->draw();

my $guy = World::Entity->new(x=>4, y=>6, name=>"Guy",room=>$room);

for(1..20)
{
	$guy->move(1,0);
	$guy->look();
}

#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

use World::Room;
use World::Feature;

my $room = World::Room->new();
$room->add_feature(World::Feature->new(char=>'.'));
$room->add_feature(World::Feature->new(char=>'#',solid=>1,opaque=>1));
$room->add_feature(World::Feature->new(char=>'|',solid=>1,opaque=>1));
$room->add_feature(World::Feature->new(char=>'+'));
$room->add_feature(World::Feature->new(char=>'%',solid=>1));
$room->add_feature(World::Feature->new(char=>'~',opaque=>1));

$room->from_string(<<MAP);
..#...........#........
.#....~~~.....|........
#.....~~~.....%........
.#....~~~.....+........
..#...........#........
MAP

$room->draw();

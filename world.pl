#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

use SDLx::App;
use SDL::Event;

my $to_draw;
my $app = SDLx::App->new();

$app->add_event_handler( sub { my $e = shift; return if ( $e->type == SDL_QUIT ); return 1 } );

$app->add_show_handler( sub { $to_draw->update(); } );
$app->add_show_handler( sub { $app->update(); } ); # This goes last!

use World::Room;
use World::Feature;
use World::Entity;

my $room = World::Room->new();
$room->add_feature(World::Feature->new(char=>'.',
                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),0,0,0)));
$room->add_feature(World::Feature->new(char=>'#',solid=>1,opaque=>1,
                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),45,45,45)));
$room->add_feature(World::Feature->new(char=>'|',solid=>1,opaque=>1,
                                       surface=>$app));
$room->add_feature(World::Feature->new(char=>'+',
                                       surface=>$app));
$room->add_feature(World::Feature->new(char=>'%',solid=>1,
                                       surface=>$app));
$room->add_feature(World::Feature->new(char=>'~',opaque=>1,
                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),200,200,200)));

$room->from_string(<<MAP);
##############
###........###
#.##......##.#
#..##....##..#
#...##..##...#
#....#~~#....#
#....~..~....#
#....#~~#....#
#...##..##...#
#..##....##..#
#.##......##.#
###........###
##..........##
##############
MAP

$room->add_entity(World::Entity->new(x=>9, y=>11, name=>"Guy",room=>$room,
                                     surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),0,0,255)));
$room->add_entity(World::Entity->new(x=>11, y=>6, name=>"Guy2",room=>$room,
                                     surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),0,255,0)));
$room->add_entity(World::Entity->new(x=>2, y=>6, name=>"Guy2",room=>$room,
                                     surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),255,0,0)));

sub random_int_between {
	my($min, $max) = @_;
	# Assumes that the two arguments are integers themselves!
	return $min if $min == $max;
	($min, $max) = ($max, $min)  if  $min > $max;
	return $min + int rand(1 + $max - $min);
}

$to_draw = $room;

my %move_dt;
foreach my $entity (@{$to_draw->entities})
{
	$move_dt{$entity->name} = 0;
	$app->add_move_handler(sub 
	                       {
		                       my $dt = shift;
		                       $move_dt{$entity->name} += $dt;
		                       if ($move_dt{$entity->name} >= 300)
		                       {
			                       $entity->move(random_int_between(-1,1),random_int_between(-1,1));
			                       $entity->learn_map();
			                       $move_dt{$entity->name} = 0;
		                       }
	                       });
}

$app->run();

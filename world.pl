#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

sub random_int_between {
	my($min, $max) = @_;
	# Assumes that the two arguments are integers themselves!
	return $min if $min == $max;
	($min, $max) = ($max, $min)  if  $min > $max;
	return $min + int rand(1 + $max - $min);
}

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
use World::Explorer;

my $room = World::Room->new();
$room->add_feature(World::Feature->new(char=>'.',
                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),0,90,0)));
$room->add_feature(World::Feature->new(char=>'#',solid=>1,opaque=>1,
                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),45,45,45)));
$room->add_feature(World::Feature->new(char=>'|',solid=>1,opaque=>1,
                                       surface=>$app));
$room->add_feature(World::Feature->new(char=>'+',
                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),92,51,23)));
$room->add_feature(World::Feature->new(char=>'%',solid=>1,
                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),45,255,255)));
$room->add_feature(World::Feature->new(char=>'~',opaque=>1,
                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),200,200,200)));

$room->from_string(<<MAP);
##################################################
#......#...................~~~~~~#...............#
#......%.......#.............~~~~#...............#
#......#.......#...............~~#...............#
###.#######.####################~###.#############
#..............#................~#.......#.......#
#......#.......#................~#...............#
####%############.############.######%#########.##
#~~~~~~#~~~~~~~#.................#...............#
#~~~~......~~~~%......#..........#.......#.......#
#~~....#....~~~#......#..........#.......#.......#
###########..########.#########.####.##########%##
#~.....#.......#......#..........#.......#.......#
#~~............#......%....##....#...............#
#~~~...........#......#....##....##########......#
#~.....#.......#......#..........~~~~~~~~~%......#
####.#############...###.######################.##
#......#.......#......#...........#.......#......#
#.....................+...................##.....#
#......#.......#......#...........##.............#
##################################################
MAP

for(1..1)
{
	$room->add_entity(World::Explorer->new(x=>1, y=>17,
	                                       name=>"Explorer".$_,room=>$room,
	                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),0,0,255)));
}

for(1..7)
{
	$room->add_entity(World::Entity->new(x=>random_int_between(1,$room->width), y=>random_int_between(1,$room->height),
	                                       name=>"Entity".$_,room=>$room,
	                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),0,0,255)));
}


$to_draw = $room->entities->[0];

my %move_dt;
my ($go_x,$go_y) = (48,2);
foreach my $entity (grep {$_->isa('World::Explorer')} @{$room->entities})
{
	$move_dt{$entity->name} = 0;
	$app->add_move_handler(sub 
	                       {
		                       my $dt = shift;
		                       $move_dt{$entity->name} += $dt;
		                       if ($move_dt{$entity->name} >= 100)
		                       {			                       
			                       $entity->learn_map();

			                       if(!$entity->move_to($go_x,$go_y))
			                       {
				                       $go_x = random_int_between(1,$room->width-2);
				                       $go_y = random_int_between(1,$room->height-2);
			                       }
			                       $move_dt{$entity->name} = 0;
		                       }
	                       });
}

$app->run();

#!/usr/bin/perl
use strict;
use warnings;

sub random_int_between {
	my($min, $max) = @_;
	# Assumes that the two arguments are integers themselves!
	return $min if $min == $max;
	($min, $max) = ($max, $min)  if  $min > $max;
	return $min + int rand(1 + $max - $min);
}

sub random_free_coordinates
{
	my $room = shift;
	my ($x,$y);
	do
	{
		$x = random_int_between(0,$room->width);
		$y = random_int_between(0,$room->height);
	} while($room->check_solid($x,$y));
	return ($x,$y);
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

for(1..5)
{
	my ($r,$g,$b) = (random_int_between(0,255),random_int_between(0,255),random_int_between(0,255));
	my ($x,$y) = random_free_coordinates($room);
	$room->add_entity(World::Explorer->new(x=>$x, y=>$y,
	                                       name=>"Explorer".$_,room=>$room,
	                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),$r,$g,$b),
	                                       go_x=>48,go_y=>2));
}

for(1..5)
{
	my ($x,$y) = random_free_coordinates($room);
	$room->add_entity(World::Entity->new(x=>$x,y=>$y,
	                                     name=>"Entity".$_,room=>$room,
	                                     surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),0,0,255)));
}

my $count = 1;
$to_draw = $room->entities->[0];

foreach my $entity (grep {$_->isa('World::Explorer')} @{$room->entities})
{
	$app->add_move_handler(sub 
	                       {
		                       my $dt = shift;
		                       $entity->dt($entity->dt+$dt);
		                       if ($entity->dt >= 100)
		                       {			                       
			                       $entity->learn_map();

			                       if(!$entity->move_to($entity->go_x,$entity->go_y))
			                       {
				                       $entity->go_x(random_int_between(1,$room->width-2));
				                       $entity->go_y(random_int_between(1,$room->height-2));
			                       }
			                       $entity->dt(0);
		                       }
	                       });
}

foreach my $entity (grep {!$_->isa('World::Explorer')} @{$room->entities})
{
	$app->add_move_handler(sub 
	                       {
		                       my $dt = shift;
		                       $entity->dt($entity->dt+$dt);
		                       if ($entity->dt >= 100)
		                       {			                       
			                       $entity->learn_map();

			                       $entity->move(random_int_between(-1,1),random_int_between(-1,1));

			                       $entity->dt(0);
		                       }
	                       });
}


$app->add_event_handler(sub
                        {
	                        my $e = shift;
	                        if ( $e->type == SDL_KEYDOWN )
	                        {
		                        $count = ($count + 1) % @{$room->entities};
		                        $to_draw = $room->entities->[$count];
		                        $app->draw_rect(undef,0);
	                        }
	                        return 1
                        });

$app->run();

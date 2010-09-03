#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $save_screens;
GetOptions('save' => \$save_screens);

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
	} while ($room->check_solid($x,$y));
	return ($x,$y);
}


use SDLx::App;
use SDL::Event;

my $to_draw;
my $app = SDLx::App->new(dt=>100);


$app->add_event_handler( sub { my $e = shift; return if ( $e->type == SDL_QUIT ); return 1 } );

$app->add_show_handler( sub { $app->draw_rect(undef,0); $to_draw->look(); } );
$app->add_show_handler( sub { $app->update(); } ); # This goes last!

use World::Room::Demo;
use World::Explorer;

my $room = World::Room::Demo->new();

for (1..5)
{
	my ($r,$g,$b) = (random_int_between(0,255),random_int_between(0,255),random_int_between(0,255));
	my ($x,$y) = random_free_coordinates($room);
	$room->add_entity(World::Explorer->new(x=>$x, y=>$y,
	                                       name=>"Explorer".$_,room=>$room,
	                                       surface=>$app,gfx_color=>SDL::Video::map_RGB($app->format(),$r,$g,$b),
	                                       go_x=>48,go_y=>2));
}

for (1..5)
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
		                       if (!$entity->move_to($entity->go_x,$entity->go_y))
		                       {
			                       $entity->go_x(random_int_between(1,$room->width-2));
			                       $entity->go_y(random_int_between(1,$room->height-2));
		                       }
		                       $entity->learn_map();
	                       });
}

foreach my $entity (grep {!$_->isa('World::Explorer')} @{$room->entities})
{
	$app->add_move_handler(sub 
	                       {
		                       $entity->move(random_int_between(-1,1),random_int_between(-1,1));
		                       $entity->learn_map();
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

my $save_count = 0;
if ($save_screens)
{
	$app->add_move_handler(sub 
	                       {
		                       SDL::Video::save_BMP( $app, "screens/screen".$save_count++.".bmp" );
	                       });
}


$app->run();

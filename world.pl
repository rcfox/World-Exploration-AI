#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use Utility;
use Getopt::Long;

use SDLx::App;
use SDL::Event;

use World::Room::Demo;
use World::Explorer;
use World::Item;

# Initialize the room and the inhabitants.
my $room = World::Room::Demo->new();

for (1..5)
{
	my ($r,$g,$b) = (255,0,0);
	my ($x,$y) = $room->random_free_coordinates();
	$room->add_item(World::Item->new(x=>$x, y=>$y,
	                                 name=>"Item".$_,room=>$room,
	                                 gfx_color=>rgb2c($r,$g,$b)));
}

for (1..25)
{
	my ($r,$g,$b) = (random_int_between(0,255),random_int_between(0,255),random_int_between(0,255));
	my ($x,$y) = $room->random_free_coordinates();
	$room->add_entity(World::Explorer->new(x=>$x, y=>$y,
	                                       name=>"Explorer".$_,room=>$room,
	                                       gfx_color=>rgb2c($r,$g,$b),
	                                       go_x=>48,go_y=>2));
}

# Set up the SDL Window
my $app = SDLx::App->new(dt=>100);
my $to_draw = $room->entities->[0];

# Quit properly when told to do so.
$app->add_event_handler(sub
                        {
	                        my $e = shift;
	                        return if ( $e->type == SDL_QUIT );
	                        return 1
                        });

# Update the screen
$app->add_show_handler(sub
                       {
	                       $app->draw_rect(undef,0);
	                       $to_draw->look();
	                       #$to_draw->fov_test();
                       });

$app->add_show_handler(sub { $app->update(); }); # This goes last!

foreach my $item (@{$room->items})
{
	$item->surface($app);
}

foreach my $entity (@{$room->entities})
{
	$entity->surface($app);

	# Each entity will walk to a random point in the world.
	$app->add_move_handler(sub 
	                       {
		                       if (!$entity->move_to($entity->go_x,$entity->go_y))
		                       {
			                       my ($x,$y) = $room->random_free_coordinates();
			                       $entity->go_x($x);
			                       $entity->go_y($y);
		                       }
		                       $entity->learn_map();
	                       });
}

# If a key is pressed, switch the entity that we're following.
$app->add_event_handler(sub
                        {
	                        my $e = shift;
	                        state $count = 0;
	                        if ( $e->type == SDL_KEYDOWN )
	                        {
		                        $count = ($count + 1) % @{$room->entities};
		                        $to_draw = $room->entities->[$count];
		                        $app->draw_rect(undef,0);
	                        }
	                        return 1
                        });

# Sets whether or not to save each frame, for making a video.
my $save_count = 0;
my $save_screens;
GetOptions('save' => \$save_screens);

if ($save_screens)
{
	$app->add_move_handler(sub 
	                       {
		                       SDL::Video::save_BMP( $app, "screens/screen".$save_count++.".bmp" );
	                       });
}

$app->run();

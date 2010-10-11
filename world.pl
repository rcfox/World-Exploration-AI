#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use Utility;
use Getopt::Long;

use World::Room::Demo;
use World::Explorer;
use World::Item;

use GUI;
my $gui = GUI->new();

# Initialize the room and the inhabitants.
my $room = World::Room::Demo->new();

for (1..50)
{
	my ($r,$g,$b) = (255,0,0);
	my ($x,$y) = $room->random_free_coordinates();
	$room->add_item(World::Item->new(x=>$x, y=>$y,
	                                 name=>"Item".$_,room=>$room,
	                                 gfx_color=>rgb2c($r,$g,$b),
	                                 surface=>$gui->app));
}

for (1..25)
{
	my ($r,$g,$b) = (random_int_between(0,255),random_int_between(0,255),random_int_between(0,255));
	my ($x,$y) = $room->random_free_coordinates();
	$room->add_entity(World::Explorer->new(x=>$x, y=>$y,
	                                       name=>"Explorer".$_,room=>$room,
	                                       gfx_color=>rgb2c($r,$g,$b),
	                                       go_x=>48,go_y=>2,
	                                       surface=>$gui->app));
}

$gui->add_click_handler(sub
                        {
	                        my ($x,$y) = @_;
	                        if ($room->map->[$y]->[$x]->char eq '#')
	                        {
		                        $room->map->[$y]->[$x] = $room->map_legend->{'.'}->clone();
	                        } else
	                        {
		                        $room->map->[$y]->[$x] = $room->map_legend->{'#'}->clone();
	                        }
                        });

foreach my $entity (@{$room->entities})
{
	# Each entity will walk to a random point in the world.
	$gui->add_tick_handler(sub 
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
$gui->add_key_handler('space', sub
                      {
	                      state $count = 0;
	                      $count = ($count + 1) % @{$room->entities};
	                      $gui->to_draw($room->entities->[$count]);
	                      $gui->app->draw_rect(undef,0);
                      });
$gui->add_key_handler('escape', sub { exit(0); });

$gui->to_draw($room->entities->[0]);
$gui->run();

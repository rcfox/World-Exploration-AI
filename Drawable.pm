package Drawable;
use Moose::Role;

use SDL::Rect;
use SDL::Color;

with 'Positionable';

has 'gfx_rect' =>
    (
        is => 'rw',
        isa => 'SDL::Rect',
        lazy => 1,
        default => sub { my $self = shift;
                         new SDL::Rect($self->x*32,$self->y*32,32,32);
                       },
    );

has 'gfx_color' =>
    (
        is => 'rw',
        isa => 'Int',
        lazy => 1,
        default => sub { SDL::Video::map_RGB(shift()->surface->format(),0,0,0); },
    );

has 'surface' =>
    (
	    is => 'rw',
	    isa => 'SDL::Surface',
	);

sub draw
{
	my $self = shift;
	$self->surface->draw_rect($self->gfx_rect,$self->gfx_color);
}

after 'place' => sub
{
    my $self = shift;
    $self->gfx_rect->x($self->x * $self->gfx_rect->w);
    $self->gfx_rect->y($self->y * $self->gfx_rect->h);
};

1;


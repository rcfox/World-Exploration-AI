package Drawable;
use Moose::Role;

use SDL::Rect;

use Utility;

with 'Positionable';

has 'gfx_rect' =>
    (
        is => 'rw',
        isa => 'SDL::Rect',
        lazy => 1,
        default => sub { my $self = shift;
                         new SDL::Rect($self->x*16,$self->y*16,16,16);
                       },
    );

has 'gfx_color' =>
    (
        is => 'rw',
        isa => 'Int',
        lazy => 1,
        default => sub{rgb2c(0,0,0)},
    );

sub draw
{
	my $self = shift;
	my $surface = shift;
	$surface->draw_rect($self->gfx_rect,$self->gfx_color);
}

after 'place' => sub
{
    my $self = shift;
    $self->gfx_rect->x($self->x * $self->gfx_rect->w);
    $self->gfx_rect->y($self->y * $self->gfx_rect->h);
};

1;


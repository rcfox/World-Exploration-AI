package SightRange;
use Moose::Role;

with 'Drawable';

after 'draw' => sub
{
	my $self = shift;
	my $surface = shift;
	my ($x,$y) = ($self->x*16+8,$self->y*16+8);
	my $length = ($self->sight_range+2)*16/sqrt(2); # I'm not entirely sure of why I need to add 2...
	my $deg2rad = 3.14159/180;
	my $maxa = $self->sight_angle/2 + $self->facing;
	my $mina = -$self->sight_angle/2 + $self->facing;
	my $line1 = [$length*cos($mina*$deg2rad)+$x,$length*sin($mina*$deg2rad)+$y];
	my $line2 = [$length*cos($maxa*$deg2rad)+$x,$length*sin($maxa*$deg2rad)+$y];
	my $white = 0xFFFFFFFF;
	
	$surface->draw_line([$x,$y],$line1,$white,0);
	$surface->draw_line([$x,$y],$line2,$white,0);
	SDL::GFX::Primitives::arc_color( $surface, $x, $y, $length, $mina, $maxa, $white);
};

1;


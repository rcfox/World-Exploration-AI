package World::Room::Demo2;
use Moose;

extends 'World::Room';

sub BUILD
{
	my $self = shift;
	
	$self->add_feature(World::Feature->new(char=>'.',                      gfx_color=>0x005A00));
	$self->add_feature(World::Feature->new(char=>'#', solid=>1, opaque=>1, gfx_color=>0x2D2D2D));
	$self->add_feature(World::Feature->new(char=>'|', solid=>1, opaque=>1, gfx_color=>0x2D2D2D));
	$self->add_feature(World::Feature->new(char=>'+',                      gfx_color=>0x5C3317));
	$self->add_feature(World::Feature->new(char=>'%', solid=>1,            gfx_color=>0x2DFFFF));
	$self->add_feature(World::Feature->new(char=>'~',           opaque=>1, gfx_color=>0xC8C8C8));

	$self->from_string(<<MAP);
##################################################
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
#................................................#
##################################################
MAP

}

1;

package World::Item;
use Moose;

with 'Positionable', 'Drawable';

has 'name' => (isa => 'Str', is => 'rw');
has 'room' => (isa => 'World::Room', is => 'rw');

1;

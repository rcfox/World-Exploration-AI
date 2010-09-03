package Controllable;
use Moose::Role;

has 'go_x' => (isa => 'Int', is => 'rw');
has 'go_y' => (isa => 'Int', is => 'rw');

1;


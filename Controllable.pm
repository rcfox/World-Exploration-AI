package Controllable;
use Moose::Role;

has 'dt' => (isa => 'Num', is => 'rw', default => 0);
has 'go_x' => (isa => 'Int', is => 'rw');
has 'go_y' => (isa => 'Int', is => 'rw');

1;


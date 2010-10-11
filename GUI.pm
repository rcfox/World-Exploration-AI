package GUI;
use Moose;
use Getopt::Long;

use SDLx::App;
use SDL::Event;

has 'app' => (isa => 'SDLx::App',
              is => 'rw');

has 'to_draw' => (isa => 'Viewable',
                  is => 'rw');

sub BUILD
{
	my $self = shift;

	my $app = SDLx::App->new(dt=>100);
	$app->add_event_handler(sub
	                        {
		                        my $e = shift;
		                        return if ( $e->type == SDL_QUIT );
		                        return 1
	                        });	
	$app->add_show_handler(sub
	                       {	                       
		                       $app->draw_rect(undef,0);
		                       $self->to_draw->look($self->app);
	                       });
	$app->add_show_handler(sub { $app->update(); }); # This goes last!

	$self->app($app);
	
	# Sets whether or not to save each frame, for making a video.
	my $save_count = 0;
	my $save_screens;
	GetOptions('save' => \$save_screens);
	
	if ($save_screens)
	{
		$self->app->add_move_handler(sub 
		                             {
			                             SDL::Video::save_BMP( $self->app, "screens/screen".$save_count++.".bmp" );
		                             });
	}	
}

sub add_click_handler
{
	my $self = shift;
	my $code = shift;

	$self->app->add_event_handler(sub
	                              {
		                              my $e = shift;
		                              if ( $e->type == SDL_MOUSEBUTTONUP )
		                              {
			                              my ($mask,$x,$y) = @{ SDL::Events::get_mouse_state( ) };
			                              $x = int($x / 16);
			                              $y = int($y / 16);

			                              $code->($x,$y);
		                              }
		                              return 1
	                              });
}

sub add_key_handler
{
	my $self = shift;
	my $key = shift;
	my $code = shift;

	$key = uc($key) if (length($key) > 1);
	$key = eval "SDLK_$key";
	
	# If a key is pressed, switch the entity that we're following.
	$self->app->add_event_handler(sub
	                              {
		                              my $e = shift;
		                              if ( $e->type == SDL_KEYDOWN && $e->key_sym == $key )
		                              {
			                              $code->();
		                              }
		                              return 1
	                              });
}

sub add_tick_handler
{
	my $self = shift;
	my $code = shift;

	$self->app->add_move_handler($code);
}

sub run
{
	my $self = shift;
	$self->app->run();
}

1;

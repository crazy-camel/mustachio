package Mustachio::Application;

use Data::Dump 'dump';
use JSON::Tiny 'decode_json';

use Mustachio::Response;
use Mustachio::Action;

sub new
{
	my ( $class, $args ) = ( shift, { @_ } );

	my $self = { 
		base => $args->{'base'},
		config => ( $args->{'base'}->child( 'config', 'app.json' )->is_file() ) 
					? decode_json( $args->{'base'}->child( 'config', 'app.json' )->slurp_utf8() )
					: {}
	};

	if ( $self->{'config'}->{'database'} )
	{
		require Mustachio::Database;

		 $self->{'database'} = Mustachio::Database->connect( 
		 	base => $self->{'base'}->child( 'database' ),
		 	config => $self->{'config'}->{'database'}
		 );
	};

	return bless $self, $class; 
}

sub respond
{
	my ($self, $query) = @_;
	
	my $action = Mustachio::Action->new( 
		path_info => $query->path_info,
		query_string => $query->query_string
	);

	my $response = Mustachio::Response->new( 
						query => $query,
						base => $action->base,
						model => $action->json
					);


	if ( $action->filter )
	{
		return $response->filter(
			filter => $action->filter
			)->refine(
			parameters => $action->parameters
			)->generate();
	}

	if ( $action->view )
	{
		return $response->refine(
			parameters => $action->parameters
			)->generate();
	}

	return $response->set404(
			parameters => $action->parameters
			)->generate();

}


1;
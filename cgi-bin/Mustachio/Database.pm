package Mustachio::Database;

sub connect
{
	my ( $self, $args ) = ( shift, { @_ } );

	if ( lc( $args->{'config'}->{'driver'} ) eq 'sqlite' )
	{
		require Mustachio::Database::SQLite;
		return Mustachio::Database::SQLite->new( 
			base => $args->{'base'},
			path => $args->{'config'}->{'path'}
			)
	}

	if ( lc( $args->{'config'}->{'driver'} ) eq 'mysql' )
	{
		require Mustachio::Database::MySQL;
		return Mustachio::Database::MySQL->new( 
			host => $args->{'config'}->{'host'} || '127.0.0.1',
			port => $args->{'config'}->{'port'} || '3336',
			username => $args->{'config'}->{'username'} || 'root',
			password => $args->{'config'}->{'password'} || 'toor',
			)
	}

	return;
}


1;
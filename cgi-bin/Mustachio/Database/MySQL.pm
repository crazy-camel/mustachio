package Mustachio::Database::MySQL;

use DBI;

sub new
{
	my ( $class, $args ) = ( shift, { @_ } );
	my $dsn = join( ";" , 
		'DBI:mysql:database='.$args->{ 'database' },
		'host='.$args->{ 'host' },
		'port='.$args->{ 'port' }
	);
	return bless {
		db => DBI->connect( $dsn, $args->{'username'},  $args->{'password'}, {'RaiseError' => 1} )
	}, $class;
}

1;
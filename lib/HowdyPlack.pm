package HowdyPlack;

use Moose;
use namespace::autoclean;
use Carp qw/croak/;
use Module::Find;
use List::MoreUtils;
use attributes;

use HowdyPlack::Request;
use HowdyPlack::Response;

use Data::Dumper;

BEGIN {
	extends 'HowdyPlack::Base';
}

#====================================================================
#
#  Instance Method
#
#====================================================================

has 'req' => (
	is     => 'ro',
	writer => '_set_req',
	isa    => 'HowdyPlack::Request'
);

has 'res' => (
	is     => 'ro',
	writer => '_set_res',
	isa    => 'HowdyPlack::Response'
);

has '_env' => ( is => 'rw' );

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	return $class->$orig( _env => $_[0] );
};

sub BUILD {
	my $self = shift;

	$self->_set_req( HowdyPlack::Request->new( $self->_env ) );
	$self->_set_res( HowdyPlack::Response->new() );
}

sub dispatch {
	my $self = shift;

	my $path_info = $self->req->path_info;
	my ( $controller, $method, $path_arguments ) =
	  $self->_choose_action($path_info);
	  
	print "controller: $controller, method: $method\n";

	if ( defined $controller ) {

		#temp

		#call begin & call method
		if ( $controller->begin($self) ) {
			
			$controller->$method($self);
		}

		#call end
		$controller->end($self);
	}
	else {
		croak "Unknow url. Implement Root::default to handle unknow url";
	}
}

#====================================================================
#
#  Class Method
#
#====================================================================
our @controllers;
our %controller_action;
our %url_map;

sub setup {
	my $class = shift;

	my @reserved = qw/meta new/;

	@controllers = useall $class->meta->name . "::Controller";

	foreach my $c (@controllers) {
		next unless $c->can('meta');
		my @ancestor = $c->meta->class_precedence_list;
		next unless grep { $_ eq 'HowdyPlack::Controller' } @ancestor;

		$controller_action{$c} = [];

		my @methods = $c->meta->get_method_list;

		foreach my $m (@methods) {
			next if lcfirst($m) ne $m;    #UPCASE method
			next if grep { $_ eq $m } @reserved;    #reserved method

			my @attr = attributes::get( $c->can($m) );
			next if @attr == 0;                     #attribute "Action"
			push @{ $controller_action{$c} },
			  {
				name  => $m,
				attrs => \@attr
			  };
		}
	}

	print "=" x 104, "\n";
	printf "|%-20s|%-60s|%-20s|\n", "url", "controller", "method";
	print "=" x 104, "\n";

	foreach my $c ( keys %controller_action ) {
		my $cc = $c;
		$cc =~ s/^.*?::Controller:://g;    #Remove prefix
		$cc =~ s/^Root$//g;                #Controller::Root is default

		my $controller_url = join "/", split /::/, lc($cc);
		foreach my $m ( @{ $controller_action{$c} } ) {

			next
			  if grep { $_ eq 'Private' }
				  @{ $m->{attrs} };        #No url map for action with 'Private'

			my $url = $controller_url . "/" . lc( $m->{name} );
			$url = "/" . $url unless $url =~ /^\//;

			printf "|%-20s|%-60s|%-20s|\n", $url, $c, $m->{name};
			$class->_store_url_map( $url, $c, $m->{name} );
		}

	}

	print "=" x 104, "\n";
}

sub _store_url_map {
	my $class = shift;

	my ( $url, $controller, $method ) = @_;

	my @url_parts = split /\//, $url;

	my $root = \%url_map;
	foreach my $p (@url_parts) {
		$root->{$p} = {} unless exists $root->{$p};
		$root = $root->{$p};
	}
	$root->{ACTION} = {
		c => $controller,
		m => $method
	};
}

sub _choose_action {
	my $class = shift;

	my ($url) = @_;
	my @url_parts = split /\//, $url;

	my $root  = \%url_map;
	my $index = 0;
	foreach my $p (@url_parts) {
		if ( exists $root->{$p} ) {
			$root = $root->{$p};
			++$index;
		}
		else {
			last;
		}
	}

	my ( $c, $m, $path_param );

	if (   @url_parts == $index
		&& exists $root->{index}
		&& exists $root->{index}->{ACTION} )
	{

		#controller without action, index is default

		$c = $root->{index}->{ACTION}->{c};
		$m = $root->{index}->{ACTION}->{m};
	}
	elsif ( exists $root->{ACTION} ) {

		#controller with action
		$c = $root->{ACTION}->{c};
		$m = $root->{ACTION}->{m};
	}
	else {

		#not found
		if ( exists $url_map{''}{default}{ACTION} ) {
			$c = $url_map{''}{default}{ACTION}{c};
			$m = $url_map{''}{default}{ACTION}{m};
		}
	}

	my @tail;
	push @tail, $url_parts[$_] foreach ( $index .. $#url_parts );
	$path_param = $index > $#url_parts ? "" : join "/", @tail;

	return defined $c ? ( $c, $m, $path_param ) : undef;
}

no Moose;
__PACKAGE__->meta->make_immutable;


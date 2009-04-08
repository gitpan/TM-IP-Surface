package TM::IP::Surface;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use parent qw/Catalyst/;
use Catalyst qw/-Debug
                -Log=INFO
                ConfigLoader
                Static::Simple/;
our $VERSION = '0.02';

__PACKAGE__->config( 'name' => 'TM::IP::Surface');
__PACKAGE__->log(Catalyst::Log->new( 'warn', 'error' ));
__PACKAGE__->setup();


=head1 NAME

TM::IP::Surface - REST service for Topic Maps surfaces

=head1 ABSTRACT

This Catalyst controller offers RESTful services to interact with
surface images of Topic Maps. It does not create these surfaces (PNG
files), but autogenerates tiles from images.

=head1 SYNOPSIS

    script/tm_ip_surface_server.pl

=head1 SEE ALSO

L<TM::IP::Surface::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Robert Barta, C<< <rho at devc.at> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under the same terms as Perl
itself.

=cut

1;

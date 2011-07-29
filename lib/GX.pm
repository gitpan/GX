# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX;

use strict;
use warnings;
use 5.010;

require GX::Application;

our $VERSION = '0.2000_01';


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

sub import {

    my $package = shift;

    return if $package ne __PACKAGE__;

    unshift @_, 'GX::Application';

    goto &GX::Application::import;

}


1;

__END__

=head1 NAME

GX - The web framework for Perl

=head1 SYNOPSIS

    package MyApp;
    
    use GX;
    
    MyApp->setup(
        engine => 'Apache2',
        mode   => 'development'
    );
    
    MyApp->start;
    
    1;

=head1 DESCRIPTION

GX is a modern, highly modular web application framework that is designed from
the ground up to be run in persistent environments like
L<FastCGI|http://www.fastcgi.com> or L<mod_perl|http://perl.apache.org>. It is
currently under heavy development and will be released to the public in summer
2011.

This is a B<pre-alpha> release for developers. The usual warnings apply.

=head1 SUPPORT

=head2 Official Website

L<http://gxframework.org/>

=head2 Mailing List

L<http://groups.google.com/group/gxframework/>

=head1 DEVELOPMENT

=head2 Public Git Repository

A public Git repository is available at L<http://git.gxframework.org>. You can
clone it using the following command:

  git clone http://git.gxframework.org

=head2 Reporting Bugs

Please report all bugs and issues via the L<CPAN Request Tracker|http://rt.cpan.org/>
or directly to C<bugs@gxframework.org>.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut

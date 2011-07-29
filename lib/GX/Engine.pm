# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Engine.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Engine;

use GX::Exception;
use GX::HTML::Util;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class ( extends => 'GX::Component::Singleton' );

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_config {

    return {
        'buffer_size'              => 8192,     #  8 KiB
        'max_request_size'         => 1048576,  #  1 MiB
        'max_request_memory_usage' => 16384     # 16 KiB
    };

}

sub _render_reload_error {

    my $invocant = shift;
    my $error    = shift;

    # The generated HTML should be kept in sync with GX::View::Error and GX::Exception::as_html()

    my $message = GX::HTML::Util::escape_html( defined $error ? "$error" : 'Reload error' );

    $message =~ s/\n/<br \/>/g;

    my $html = <<HTML;
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Reload error</title>
<meta http-equiv="Cache-Control" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="Pragma" content="no-cache" />
<meta name="robots" content="noindex, nofollow" />
<style type="text/css">
body, code, div, h1, h2, p, table, tbody, tr, td { margin:0; padding:0 }
body { padding:50px; font-size:15px; font-family:Arial, sans-serif; color:#333 }
h1 { margin:0 0 25px 0; font-size: 32px }
h2 { margin:0 0 25px 0; font-size: 24px }
li { margin-bottom:25px }
p { margin:15px 0 }
table { width:100%; empty-cells:show; border-spacing:1px }
code { font-family:"DejaVu Sans Mono", Monaco, "Lucida Console", "Andale Mono", monospace }
div.message { margin:25px 0; padding:15px; background:#F4CDCD }
div.subexceptions { margin:50px 0 }
div.stack_trace { margin:50px 0 }
div.stack_trace p strong { padding:3px 5px; background: #FEEFB3; font-size:13px; font-family:"DejaVu Sans Mono", Monaco, "Lucida Console", "Andale Mono", monospace }
div.viewport { overflow:auto }
table.source code { font-size:13px; color:#444 }
table.source td { padding:2px 5px; background:#EEE }
table.source td.line { text-align:right }
table.source td.code { width:100% }
table.source tr.highlight td { background:#E3E3E3 }
table.source tr.highlight td code { color:#333 }
</style>
</head>
<body>
<h1>Reload error</h1>
<div class="exception">
<div class="message"><code>$message</code></div>
</div>
</body>
</html>
HTML

    utf8::encode( $html );

    return $html;

}

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+?Engine$/;

}


1;

__END__

=head1 NAME

GX::Engine - Base class for engine components

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Engine> class which extends the
L<GX::Component::Singleton> class.

=head1 SUBCLASSES

The following classes inherit directly from L<GX::Engine>:

=over 4

=item * L<GX::Engine::Apache2>

=item * L<GX::Engine::FCGI>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut

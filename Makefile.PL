# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'TM-IP-Surface';
all_from 'lib/TM/IP/Surface.pm';

requires 'Catalyst::Runtime' => '5.7014';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'parent';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Catalyst::View::Mason';
requires 'HTTP::Status';
requires 'Image::Magick';
requires 'Test::More';
requires 'HTTP::Request::Common';

catalyst;

#install_script glob('script/*.pl');
auto_install;
WriteAll;

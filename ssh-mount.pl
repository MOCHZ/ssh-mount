#!/usr/bin/perl
#
# Author:       Zorko
# Year:         2015
# Email:        contact@zorko.co
# Website:      www.zorko.co
# License:      GPL v2
# License URI:  https://www.gnu.org/licenses/gpl-2.0-standalone.html
#
# A simple script to manage one or multiple sshfs mounts.
# This script is a rewrite of a concept I made a few years ago.
# Please note that this is a proof of concept script, some bugs might occur.
#
# I do not take any responsibility for any issues suffered from using this script.
#
# CONFIG
# The serverlist should consist of single lines with the following pattern
# server_nickname::user@server.com:/external/path/
#
#
use utf8;
use strict;
use warnings;
use feature 'say';
use Getopt::Long;
use Data::Dumper;

my $_HOME           = $ENV{'HOME'};
my $CONFIG_FILE     = $_HOME . '/.ssh-mounts/serverlist';

# Check to see if config file exists
unless (-e $CONFIG_FILE and -r $CONFIG_FILE) {
    say "Config file missing, please check that $CONFIG_FILE exist and is readable";
    exit;
}

# Fetch params
my %params;
GetOptions(\%params,
            's=s',
            'a!',
            '-available!',
            '-specific=s',
            'all!',
            'h!' | 'help!' => sub{ &_help() },
) || &_help('Missing parameters');

$params{'specific'}     = $params{'s'} if $params{'s'};
$params{'available'}    = $params{'a'} if $params{'a'};

open(my $fh, '<', $CONFIG_FILE) or die $!;
my @serverlist = <$fh>;
close($fh);

my @servers = &_read_config(@serverlist);

if ($params{'available'}) {
    &_show_available(@servers);
    exit 0;
}

for my $server (@servers) {
    if ((defined $params{'specific'} and $params{'specific'} =~ m{^$server->{'name'}$}) or $params{'all'}) {
        my $mount_point = sprintf('%s/mounts/%s',$_HOME, $server->{'name'});
        my $mount       = sprintf('sshfs %s %s', $server->{'address'}, $mount_point);

        unless (-e $mount_point) {
            system("mkdir -p $mount_point");
        }

        # Mount
        system($mount);
    }
}


# Help message
sub _help() {
    my $message = shift;
    
    if ($message) {
        say $message;
    }

    my @arg_spec = ({   'arg'   => '-s | --specific <SERVER_NAME>',
                        'desc'  => 'Mounts a given server in ~/.ssh-mounts/serverlist'},

                    {   'arg'   => '-all',
                        'desc'  => 'Mounts all servers in ~/.ssh-mounts/serverlist'},

                    {   'arg'   => '-a | --available',
                        'desc'  => 'Show available servers to mount'},

                    {   'arg'   => '-h | --help',
                        'desc'  => 'Show this help message'},
                );

    my $dist    = &__fix_layout('arg', @arg_spec);
    my $list_pat= '%-' . $dist . 's%s';

    # Usage example
    say $0 . ' -s <SERVER_NAME>';
    for my $opt (@arg_spec) {
        say sprintf($list_pat, $opt->{'arg'}, $opt->{'desc'});
    }

    exit 0;
}

# Handling config data
sub _read_config() {
    my @serverlist  = @_;
    my @servers;

    for my $line (@serverlist) {
        chomp($line);
        if ($line =~ m{^(.+)::(.+\@.+)$}) {
            my $name    = $1;
            my $server  = $2;

            push(@servers, {'name'      => $name, 
                            'address'   => $server,
                });
        }
    }

    return @servers;
}

sub _show_available() {
    my @servers     = @_;
    my $dist        = &__fix_layout('name', @servers);
    my $list_pat    = '%-' . $dist . 's%s';

    
    say sprintf($list_pat, '[ Name ]', '[ Address ]');
    for my $server (@servers) {
        say sprintf($list_pat, $server->{'name'}, $server->{'address'});
    }

    return;
}

# Fix layout
sub __fix_layout() {
    my $key     = shift;
    my @list    = @_;
    my $dist    = 0;

    for my $hash (@list) {
        if(length($hash->{$key}) > $dist) {
            $dist = length($hash->{$key}) + 10;
        }
    }

    return $dist;
}

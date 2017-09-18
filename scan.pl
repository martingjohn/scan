#!/usr/bin/env perl
use strict;
use warnings;

my @subnets;

if (defined $ARGV[0])
{
        foreach my $arg(@ARGV)
        {
                if ($arg=~/^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2})$/)
                {
                        #specific so leave as is
                        push @subnets,$1;
                }
                elsif ($arg=~/^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})$/)
                {
                        #no netmask - assume /24
                        push @subnets,"$1/24";
                }
        }
}
else
{
        @subnets=&get_subnets;
}

my ($name,$ip,$mac,$make);
my $output_format="%20s %-15s %-17s %-25s\n";

printf($output_format,"Name","IP","MAC","Manufacturer");

foreach my $subnet (@subnets)
{
        print "Scanning $subnet\n";
        printf($output_format,"-"x20,"-"x15,"-"x17,"-"x25);
        #Clear old ones
        undef $name;
        undef $ip;
        undef $mac;
        undef $make;

        my @scan=`nmap -sP $subnet`;

        my $count=0;
        foreach my $line (@scan)
        {
                chomp $line;
                if ($line=~/^Nmap scan report for (.*?)$/)
                {
                        #Start of host

                        #Print details if we've got some
                        if (defined $ip)
                        {
                                $count++;
                                &output;
                        }

                        #Clear old ones
                        undef $name;
                        undef $ip;
                        undef $mac;
                        undef $make;

                        my $name_host=$1;
                        if ($name_host=~/^(.*?) \((.*?)\)$/)
                        {
                                $name=$1;
                                $ip=$2;
                        }
                        else
                        {
                                $name="unknown";
                                $ip=$name_host;
                        }
                }
                elsif ($line=~/^MAC Address: (.*?) \((.*?)\)$/)
                {
                        $mac=$1;
                        $make=$2;
                }
        }
        #Print out last host
        &output;
        $count++;
        print "$subnet - $count\n";
}


sub output
{
        if (defined $ip)
        {
                #If not on local network MAC and make aren't defined
                $mac=$mac||"unknown";
                $make=$make||"unknown";
                printf($output_format,$name,$ip,$mac,$make);
        }
}

sub get_subnets
{
        my @subnets;

        my @if=`ip -o addr show`;
        foreach my $line (@if)
        {
                next if $line=~/ lo /;
                next if $line=~/ docker/;
                next if $line=~/ br-/;
                chomp $line;
                if ($line=~/^.*?inet (.*?) .*?$/)
                {
                        push @subnets,$1;
                }
        }
        return @subnets;
}

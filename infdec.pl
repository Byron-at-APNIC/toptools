#!/usr/bin/perl -w

use strict;
use warnings;

binmode STDIN;

sub foffpeeks
{
    my $in = shift;

    $in =~ s/\(Incl(?:udes)? Sneak Peek[^\)]*\)?//g;
    $in =~ s/\s*$//g;
    return $in;
}

sub nul
{
    my $in = shift;
    $in =~ s/\0.*//;
    return $in;
}

my $inf = do { local $/ = undef; <STDIN>; };
my (
    $magic,
    $version, $startTime, $duration, $durationSeconds,
    $flags, $serviceData, $serviceName, $videoType, $audioType,
    $eventSeconds, $eventMinutes, $eventId, $eventStart, $eventEnd,
    $eventStatus, $eventNameLength, $eventParentalRate
) = unpack("A4(xxSLSS)<(Sx10a14A24CC)<(xxCCLLL)<CCC", $inf);
printf "top_version=\"%s 0x%04x\"\n", $magic, $version;
printf "top_start=0x%08x\ntop_start_wtf=\"(%d, %s)\"\n", $startTime, $startTime, scalar(localtime($startTime));
printf "top_duration=\"%d:%02d\"\n", $duration, $durationSeconds;
printf "top_flags=0x%04x\n", $flags;
printf "top_service=%s\n", quotemeta nul $serviceName;
printf "top_video_audio=\"%d %d\"\n", $videoType, $audioType;
printf "top_event_duration=\"%d:%02d\"\n", $eventMinutes, $eventSeconds;
printf "top_event_id=\"%d\"\n", $eventId;
#printf "#Event start/end: 0x%04x - 0x%04x\n", $eventStart, $eventEnd;
#printf "#Event status/name/parental rate: %d %d %d\n", $eventStatus, $eventNameLength, $eventParentalRate;
my $eventName = substr($inf, 0x57, $eventNameLength);
print "top_event_name=", quotemeta foffpeeks $eventName;
print "\n";
my $eventInfo = unpack("Z*", substr($inf, 0x57 + $eventNameLength, 273 - $eventNameLength));
print "top_event_info=", quotemeta foffpeeks $eventInfo;
print "\n";

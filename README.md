[![Build Status](https://travis-ci.org/artm/ipod_db.png)](https://travis-ci.org/artm/ipod_db)

[![Code Climate](https://codeclimate.com/github/artm/ipod_db.png)](https://codeclimate.com/github/artm/ipod_db)
NAME
====

    ipod_db v0.2.13

SYNOPSIS
========

    ipod_db (sync|ls|rm) [options]+

DESCRIPTION
===========

    A couple of tools for working with iPod Shuffle (2nd gen) database from
    command line. Each subcommand understands -h/--help flag.

PARAMETERS
==========

    --books=books, -b (0 ~> books=books) 
        subdirectory of ipod with bookmarkable media 
    --songs=songs, -s (0 ~> songs=songs) 
        subdirectory of ipod with non-bookmarkable media 
    --version, -v 
        show package version and exit 
    --help, -h 

AUTHOR
======

    artm <femistofel@gmail.com>


SUBCOMMAND: sync
================

SYNOPSIS
========

    ipod_db sync [options]+

DESCRIPTION
===========

    Update the iPod database. Given directories of bookmarkable and non-bookmarkable
    media 'ipod' will find all supported tracks add them to the iPod database so
    the device is aware of their existance.
    
    The tracks under 'books' folder will get "riffled" - tracks from the same folder
    are spread out in the list so they don't follow each other if possible. IN THE
    FUTURE it is planned to allow configuring of track groups which are treated like
    single folders - e.g. to spread out all SciAm's "60 second somthing" podcasts along
    the playlist.
    
    It is perfectly possible to have other directories full of tracks in device's
    subconscious - e.g. when time-sharing the device among members of a poor
    family. Just make sure you update the database using your directories when
    receiving it from a relation.
    
    iPod remembers playback position on bookmarkable media and the 'ipod' goes
    out of its way to preserve the bookmarks. It also removes bookmarkable files
    from shuffle list.
    
    I configure gpodder to place podcast files inside IPOD/books directory and delete
    them after syncing. Having copied podcasts I run 'ipod sync' to update the
    database on the device and it's ready for consumption.

PARAMETERS
==========

    --books=books, -b (0 ~> books=books) 
        subdirectory of ipod with bookmarkable media 
    --songs=songs, -s (0 ~> songs=songs) 
        subdirectory of ipod with non-bookmarkable media 
    --version, -v 
        show package version and exit 
    --help, -h 

SUBCOMMAND: ls
==============

SYNOPSIS
========

    ipod_db ls [options]+

DESCRIPTION
===========

    produce a colorful listing of the tracks in the ipod database

PARAMETERS
==========

    --books=books, -b (0 ~> books=books) 
        subdirectory of ipod with bookmarkable media 
    --songs=songs, -s (0 ~> songs=songs) 
        subdirectory of ipod with non-bookmarkable media 
    --version, -v 
        show package version and exit 
    --help, -h 

SUBCOMMAND: rm
==============

SYNOPSIS
========

    ipod_db rm track track* [options]+

DESCRIPTION
===========

    Remove tracks from the device by their numbers (that's why ls
    displays numbers: so it's easier to select them for rm).

PARAMETERS
==========

    track (-2 -> track) 
         track numbers to delete from device (ranges like 2-5 are accepted 
        too). As a special case, the word 'done' means all finished tracks, 
        i.e. with play count above zero or progress above 97% 
    --books=books, -b (0 ~> books=books) 
        subdirectory of ipod with bookmarkable media 
    --songs=songs, -s (0 ~> songs=songs) 
        subdirectory of ipod with non-bookmarkable media 
    --version, -v 
        show package version and exit 
    --pretend, -n 
        don't delete, just list what would be deleted 
    --help, -h 

HISTORY
=======

    I used to do the same sort of thing and more with a bunch of python scripts.
    My cheapo mass-storage mp3 player has died recently and my son has donated
    (voluntarily) his Shuffle to me, but python scripts were all bit-rot and
    refused to work and I haven't touched python for several years already, so
    I rewrote the main script in ruby. The reading part of python version still
    worked so I made it dump what it read in ruby-esque format for testing
    (that's test_data.rb). The test_data isn't very exciting though (all
    tracks are in default state without bookmarks).

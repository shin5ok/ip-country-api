use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'IP_Country::API',
    AUTHOR           => q{shin5ok <shin5ok@55mp.com>},
    VERSION_FROM     => 'lib/IP_Country/API.pm',
    ABSTRACT_FROM    => 'lib/IP_Country/API.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
        'NetAddr::IP' => 0,
        'Class::Accessor::Lite' => 0,
        'Redis' => 0,
        'Furl' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'IP_Country-API-*' },
);

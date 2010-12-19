use inc::Module::Install;
name 'Plack-Middleware-Perl-Info';
all_from 'lib/Plack/Middleware/Perl/Info.pm';

requires 'Parallel::Scoreboard' => 0.02;
requires 'Data::MessagePack'    => 0.34;

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;

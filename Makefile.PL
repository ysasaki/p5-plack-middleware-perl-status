use inc::Module::Install;
name 'Plack-Middleware-Perl-Info';
all_from 'lib/Plack/Middleware/Perl/Info.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;

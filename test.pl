# Test suite for the Tie::ShadowHash Perl module.  Before make install is
# performed, run tests with make test.  After make install, it should work
# as perl test.pl.

# Locate the test data directory for later use.
my $data;
for (qw(./test ./t/test ../t/test)) { $data = $_ if -d $_ }
unless ($data) { die "Cannot find test data directory\n" }

# Print out the count of tests we'll be running.
BEGIN { $| = 1; print "1..22\n" }

# 1 (ensure module can load, and generate DBM database)
END { print "not ok 1\n" unless $loaded }
use Tie::ShadowHash;
use AnyDBM_File;
use Fcntl qw(O_CREAT O_RDONLY O_RDWR);
$loaded = 1;
my (%hash, $obj);
$obj = tie (%hash, 'AnyDBM_File', "$data/first", O_RDWR | O_CREAT, 0644);
if ($obj) {
    open (DATA, "$data/first.txt")
        or die "Can't open $data/first.txt: $!\n";
    while (<DATA>) {
        chomp;
        $hash{$_} = 1;
    }
    close DATA;
    untie %hash;
} else {
    die $!;
    print 'not ';
}
print "ok 1\n";

# 2 (try tying just the text file)
$obj = tie (%hash, 'Tie::ShadowHash', "$data/second.txt");
print 'not ' unless $obj;
print "ok 2\n";

# 3, 4 (check the data)
print ($hash{admin} == 1   ? '' : 'not ', "ok 3\n");
print (!exists $hash{meta} ? '' : 'not ', "ok 4\n");

# 5-9 (check overriding)
$hash{meta} = 2;
$hash{admin} = 2;
print ($hash{meta}  == 2   ? '' : 'not ', "ok 5\n");
print ($hash{admin} == 2   ? '' : 'not ', "ok 6\n");
print ($hash{jp}    == 1   ? '' : 'not ', "ok 7\n");
delete $hash{jp};
print (!exists $hash{jp}   ? '' : 'not ', "ok 8\n");
$hash{jp} = 2;
print ($hash{jp}    == 2   ? '' : 'not ', "ok 9\n");

# 10, 11 (tie just the dbm file)
undef $obj;
untie %hash;
my %db;
unless (tie (%db, 'AnyDBM_File', "$data/first", O_RDONLY, 0644)) {
    print 'not ';
}
print "ok 10\n";
$obj = tie (%hash, 'Tie::ShadowHash', \%db);
print 'not ' unless $obj;
print "ok 11\n";

# 12, 13 (check the data)
print ($hash{meta} == 1      ? '' : 'not ', "ok 12\n");
print (!defined $hash{admin} ? '' : 'not ', "ok 13\n");

# 14, 15 (check overriding)
$hash{admin} = 2;
delete $hash{meta};
print ($hash{admin} == 2     ? '' : 'not ', "ok 14\n");
print (!defined $hash{meta}  ? '' : 'not ', "ok 15\n");

# 16 (check clearing)
%hash = ();
print (!defined $hash{sg}    ? '' : 'not ', "ok 16\n");

# 17 (add back in both the text file and the db file)
$obj->add (\%db, "$data/second.txt") or print 'not ';
print "ok 17\n";

# 18-20 (check the data)
print ($hash{admin} == 1     ? '' : 'not ', "ok 18\n");
print ($hash{meta} == 1      ? '' : 'not ', "ok 19\n");
print (!defined $hash{fooba} ? '' : 'not ', "ok 20\n");

# 21 (compare a keys listing with the full data)
open (FULL, "$data/full") or die "can't open $data/full: $!\n";
my @full = sort <FULL>;
chomp @full;
my @keys = sort keys %hash;
unless (join ("\0", @full) eq join ("\0", @keys)) {
    print 'not ';
}
print "ok 21\n";

# 22 (make sure deleted keys are skipped)
delete $hash{sg};
my @keys = keys %hash;
if (@keys != @full - 1 || grep { $_ eq 'sg' } @keys) {
    print 'not ';
}
print "ok 22\n";

# Clean up after ourselves (delete first* in $data except for first.txt).
opendir (DATA, $data) or die "Can't open $data to clean up: $!\n";
for (grep { /^first/ } readdir DATA) {
    unlink "$data/$_" unless $_ eq 'first.txt';
}
closedir DATA;

#!/usr/bin/perl

my $fhemCfgTmpl = $ARGV[0];
my $fhemCfg = $ARGV[1];
my $CFG;

open( my $fh, '<', $fhemCfg ) or die "cannot open file $fhemCfg";
{
    local $/;
    $CFG = <$fh>;
}
close($fh);

@files = glob($fhemCfgTmpl);

foreach my $file (@files) {
    open( my $fh, '<', $file ) or die "cannot open file $file";
    while ( my $line = <$fh> ) {
        next if ( $line eq "\n" || $line =~ /^#/ );
        my @words = split / /, $line;
        my $cmd   = shift @words;
        my $dev   = shift @words;
        my $typ   = shift @words;
        my $val   = join( " ", @words );
        my $mod;

        # find out module name
        if ( $cmd eq "define" ) {
            $mod = $typ;
        }
        elsif ( $CFG =~ m/^define $dev (\w+|\W+).*\n/mi ) {
            $mod = $1;
        }
        elsif ( $dev ne "global" ) {
            #print "    ERROR: $dev is not defined in cfg file\n";
            next;
        }

        # handle device definitions
        if ( $cmd eq "define" ) {

            # overwrite existing define
            if ( $CFG =~ m/^$cmd $dev $mod.*\n/mi ) {
                #print "    $dev: Enforced device definition\n";
                $CFG =~ s/^$cmd $dev $mod.*\n/$line/mi;
            }

            # add new define
            else {
                #print "    $dev: Added new device\n";
                $CFG .= "\n" . $line;
            }
        }

        # handle attributes
        if ( $cmd eq "attr" ) {

            # overwrite existing attribute
            if ( $CFG =~ m/^$cmd $dev $typ .+\n/mi ) {
                #print "    $dev: Enforced attribute '$typ'\n";
                $CFG =~ s/^$cmd $dev $typ .+\n/$line/mi;
            }
            elsif ( $CFG =~ m/^define $dev $mod.*\n/mi ) {
                #print "    $dev: New attribute '$typ'\n";
                $CFG =~ s/^(define $dev $mod.*\n)/$1$line/mi;
            }
            elsif ( $dev eq "global" ) {
                #print "    $dev: New GLOBAL attribute '$typ'\n";
                $CFG =~ s/^(attr $dev .*\n)/$1$line/mi;
            }

        }

    }
    close($fh);
}

open( my $fh, '>', $fhemCfg );
print $fh $CFG;
close($fh);

#!/usr/bin/perl
use warnings;

my $option;
my $file;

do{
print "1) Parse File\n";
print "2) Exit\n";
print ">";
chomp($option = <STDIN>);
print "Okay!\n";

if($option eq 1){
    &parse_kby_file();
}

}while(($option ne 2)&&($option ne ""));

sub get_file{
    do{
        print "Enter in the kby file you want to parse okay?";
        chomp($file = <STDIN>);
        if($file eq ""){
            print "No file selected.\n";
            return "";
        }
        
        if(not ($file =~ m/\.kby$/i)){
            print "File must be of type kby.\n";
            return "";
        }

    }while(not open(kbyHandler,"<", $file));

    return $file;
}

sub parse_kby_file{
    $file = &get_file();
    if($file eq ""){
        return;
    }

    open(htmlHandler, ">", "output.html") or die $!;

    print htmlHandler "<!DOCTYPE HTML>";
    print htmlHandler "<html>\n";
    print htmlHandler "<body>\n";
    my $isParagraphOpen = 0;
    my $previous_line = "";
    while(<kbyHandler>){
        if($_ =~ /^\@{2}/){
            print htmlHandler "<h2>\n";
            print htmlHandler substr($_,2);
            print htmlHandler "</h2>\n";
        }elsif($_ =~ /^\@{1}/){
            print htmlHandler "<h1>\n";
            print htmlHandler substr($_,1);
            print htmlHandler "</h1>\n";
        }elsif($previous_line eq "\n"and not ($_ =~ /^\s*$/)){
            print htmlHandler "</p>\n<p>\n";
            print htmlHandler parse_kby_line($_);
            $isParagraphOpen = 1;
        }elsif(not ($_ =~ /^\s*$/)){
            if(not $isParagraphOpen){
                print htmlHandler "<p>\n";
                $isParagraphOpen=1;
            }
            print htmlHandler parse_kby_line($_);
        }

        $previous_line = $_;
    }

    if($isParagraphOpen){
        print htmlHandler "\n</p>\n";
    }
    print htmlHandler "</body>\n";
    print htmlHandler "</html>";

    close(htmlHandler);
    close(kbyHandler);
}

sub parse_kby_line{
    $n = scalar(@_);
    if($n==0){
        return;
    }

    $line = $_[0];
    $tempChar = chr(0);
    $line =~ s/\"\"\*/$tempChar/;

    $beginBold = "<b>";
    $endBold = "</b>";

    $line =~ s/\*(.+)\*/$beginBold . $1 . $endBold/ge;

    $line =~ s/$tempChar/\*/;

    $line =~ s/\"\"\//$tempChar/;

    $beginItal = "<em>";
    $endItal = "</em>";

    $line =~ s/\/(.+)\//$beginItal . $1 . $endItal/ge;

    $line =~ s/$tempChar/\//;
    

    return $line;
}
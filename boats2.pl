use strict;
use warnings;
use File::Spec;
use File::Copy;
use File::Path qw(make_path);
use Image::PNG::Libpng qw(read_png_file);
use MIME::Base64;
use JSON::PP;
use lib '.';

require 'config.pl';

sub walk {
    my $dir = "input";
    my @tree = glob("$dir/*.png $dir/**/*.png");
   @tree;
}

sub make_card_categories {
    my @tree = @_;
    my %cats;
    my @paths = map {
        my @d = File::Spec->splitdir($_);
        shift(@d);
        unshift(@d, title()) if (scalar @d == 1);
        my $def = read_def_from_png($_);

        if ($def) {
            $def->{data}->{"b2_source_path"} = $_;
            $def->{data}->{"href"} = File::Spec->catfile(card_output_dir(), $d[-1]);
            pop(@d);
            push(@d, $def);
        } else {
            warn ($_." could not be parsed");
        }
        \@d;
        } @tree;

    for (@paths) {
        next unless @$_ == 2;
        my ($k, $v) = @$_;
        push @{$cats{$k}}, $v;
    }

    %cats;
}

sub read_def_from_png ($) {
    my ($png) = @_;
    my $card = read_png_file($png) or die $!;
    my $chunks = $card->get_text();
    my ($chunk) = (grep { $_->{key} eq 'chara'} @$chunks);
    $chunk ? decode_json decode_base64($chunk->{text}) : undef;
}

sub trim_whitespace {
    my $s = shift;
    $s =~ s/\R//g;
    $s =~ s/\s+/ /g;
    $s =~ s/^\s+|\s+$//g;
    $s;
}

sub render_html($$) {
    my ($categories, $template) = @_;
    my $html = '';
    $template = trim_whitespace($template);

    # loop keywords
    my %loops = (
        'categories' =>  "for my \$cat_title ( sort {
            return -1 if \$a eq title();
            return 1 if \$b eq title();
            \$a cmp \$b; } keys %\$categories) { ",
        'cards' => "for my \$card (\@{\$categories->{\$cat_title}}) { ",
        'alternate_greetings' => "for my \$greeting (\@{\$card->{data}->{alternate_greetings}}) {",
        'tags' => "for my \$tag (\@{\$card->{data}->{tags}}) {",
    );

    # control keywords
    my %disp = (
        'var' => sub { "\$html .= \$card->{data}->{$_[0]};" },
        'do' => sub { $loops{$_[0]} // die "Unrecognized loop keyword \"$_[0]\" in template. Available loops: " . join(", ", sort keys %loops) . "."},
        'if' => sub { $_[0] =~ /^!/ ? "unless (\$card->{data}->{'" . substr($_[0], 1) . "'}) {" : "if (\$card->{data}->{'$_[0]'}) { " },
        'end' => sub { "} "},

        # to display iterated value in loop
        'category' => sub { "\$html .= \$cat_title;" },
        'alternate_greeting' => sub {"\$html .= \$greeting;"},
        'tag' => sub {"\$html .= \$tag;"},
    );

    $template =~ s/
    {%\s*(\w+)(?:\s+(.*?(?=\s*%})))?\s?%}
    |((?:(?!{%).)+)
    /do {
        my ($cmd, $arg, $text) = ($1, $2, $3);
        if (defined $cmd) {
            if (!exists $disp{$cmd}) { die "Unrecognized command \"$cmd\" in template. Available commands: " . join(", ", sort keys %disp) . "."; }
            $disp{$cmd}->($arg =~ s{\s+$}{}r || ''); }
        else { "\$html .= q{" . $text . "};"; }
    }/egx;

    eval $template;
    die "Template error: $@" if $@;
    $html;
}


sub copy_to_output ($$) {
    my ($html, $cats) = @_;
    make_path output_dir() or die "Can't create target directory: $!" unless (-d output_dir());
    my $card_dest = File::Spec->catdir(output_dir(), card_output_dir());
    make_path $card_dest or die "Can't create target directory $card_dest: $!" unless (-d $card_dest);

    # copy html to output
    my $html_path = File::Spec->catfile(output_dir(), html_filename());
    open (my $fh, ">", $html_path) or die "Can't open file $html_path for write: $!";
    print $fh $html;

    # copy each card source path to dest
    for my $cat (keys %{$cats}) {
        for my $card (@{$cats->{$cat}}) {
            my $src = $card->{data}->{b2_source_path};
            copy($src, $card_dest) or die "Couldn't copy $src to $card_dest: $!";
        }
    }
}

my @tree = walk;
my %cats = make_card_categories(@tree);
my $html = render_html(\%cats, html_template());
copy_to_output($html, \%cats);
print "Done\n"
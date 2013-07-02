#!/usr/bin/perl

use strict;
use warnings;

#
#  This is a temporary application that starts Bristlecone to create some load for testing.
#  The routines in this script will be soon integrated with tungsten-cookbook
#


# /opt/continuent/cookbook_test/tungsten/bristlecone/bin/evaluator.sh ~/sample_evaluator.xml

sub check_evaluator
{
    my $evaluator_pid = qx/ps aux | grep Evaluator| grep -v "grep Evaluator"|awk '{print \$2}'/;
    if ($evaluator_pid)
    {
        my @pids = grep {$_} split /\n/, $evaluator_pid;
        if (@pids > 1)
        {
            warn "Found more than one evaluator PID\n";
            return;
        }
        return $pids[0];
    }
    return;
    #my $jps = which('jps');
    #unless ($jps)
    #{
    #    warn "jps not found. Can't get evaluator's pid\n";    
    #    return -1;
    #}
    #$jps = undef;
    #$jps = qx/jps/;
    # print "# ($elapsed) $jps\n";
    #if ($jps && ($jps =~ /^(\d+)\s+evaluator/im))
    #{
    #    return $1;
    #}
    #return;
}

sub start_evaluator
{
    my ($user_values) = @_;

    my $xml_text=<<EVALUATOR_EOF;
    <!DOCTYPE EvaluatorConfiguration SYSTEM "file://someplace/evaluator.dtd">
    <EvaluatorConfiguration 
        name="mysql" 
        testDuration="1800"
        autoCommit="true" 
        statusInterval="2" 
        htmlFile="mysqlResults.html" >
        <Database driver="com.mysql.jdbc.Driver"        
            url="jdbc:mysql://127.0.0.1:$user_values->{APPLICATION_PORT}/evaluator?createDatabaseIfNotExist=true"
            user="$user_values->{APPLICATION_USER}"
            password="$user_values->{APPLICATION_PASSWORD}"/> 
         
        <TableGroup 
            name="tbl" 
            size="100">
            <ThreadGroup 
                name="A" 
                threadCount="10" 
                thinkTime="1"
                updates="15" 
                deletes="5" 
                inserts="10" 
                readSize="1000"
                rampUpInterval="5" 
                rampUpIncrement="2"/>
        </TableGroup>
    </EvaluatorConfiguration>

EVALUATOR_EOF
    
    my $evaluator_path = "$user_values->{CONTINUENT_ROOT}/tungsten/bristlecone/bin/evaluator.sh";
    unless ( -x $evaluator_path)
    {
        warn "Could not find the evaluator launcher at '$evaluator_path'\n";
        return ;
    }
    my $evaluator_running = check_evaluator();
    my $must_wait_for_cleanup =0;
    my $MYSQL= sprintf('mysql -h 127.0.0.1 -u%s -p%s -P%d ',
        $user_values->{APPLICATION_USER},
        $user_values->{APPLICATION_PASSWORD},
        $user_values->{APPLICATION_PORT} 
    );

    if ($evaluator_running)
    {
        unless ($evaluator_running == -1)
        {
            warn "Evaluator already running with pid $evaluator_running. Not started.\n";
        }
        return;
    }
    else
    {
        # evaluator not running. Checking for remnants of database 
        my $result = get_local_result(qq[$MYSQL -BN -e 'select count(*) from information_schema.tables where table_schema="evaluator" and table_name ="tbl3"' ]);
        if ($result)
        {
            $must_wait_for_cleanup = 1;
        }
    
    }
    my $child_pid = fork;
    if ($child_pid)
    {
        if ($must_wait_for_cleanup)
        {
            sleep 5;
        }
        my $timeout = 60;
        my $elapsed = 0;
        my $evaluator_pid;
        while ($elapsed < $timeout)
        {
            $evaluator_pid = check_evaluator();
            if (defined $evaluator_pid && $evaluator_pid == -1)
            {
                return;
            }
            last if $evaluator_pid;
            sleep 1;
            $elapsed++;
        }
        unless ($evaluator_pid)
        {
            warn "could not determine evaluator pid \n";
            return;
        }
        $elapsed = 0;
        while ($elapsed < $timeout)
        {
            my $result = get_local_result(qq[$MYSQL -BN -e 'select count(*) from information_schema.tables where table_schema="evaluator" and table_name ="tbl3"' ]);
            if ($result)
            {
                $result = get_local_result(qq[$MYSQL -BN -e 'select count(*) from evaluator.tbl3' ]);
            }
            # print "## ($elapsed) $result\n";
            if ($result && ($result > 1000))
            {
                write_to_tmp('evaluator.pid',"$evaluator_pid\n");
                return $evaluator_pid;
            }
            sleep 1;
            $elapsed++;
        }
    }
    else
    {
        # inside the child process
        my $evaluator_xml = 'evaluator.xml';
        my $tmpdir = write_to_tmp($evaluator_xml, $xml_text);
        # exec "screen -d -m -S evaluator $evaluator_path $evaluator_xml";
        print "$evaluator_path $tmpdir/$evaluator_xml > $tmpdir/evaluator.log \n";
        exec "$evaluator_path $tmpdir/$evaluator_xml > $tmpdir/evaluator.log 2>&1";
    }

    return ;
}

sub write_to_tmp
{
    my ($fname, $text) = @_;
    my $tmpdir = $ENV{TMPDIR} || $ENV{TEMPDIR}  || '/tmp';
    die "can't find temporary directory $tmpdir \n" unless -d $tmpdir;
    my $full_fname = $tmpdir . '/' . $fname;
    open my $FH, '>', $full_fname
        or die "can't create $full_fname ($!)\n";
    print $FH $text;
    close $FH;
    return $tmpdir;
}


#
# Custom implementation of the 'which' command.
# Returns the full path of the command being searched, or NULL on failure.
#
sub which
{
    my ($executable) = @_;
    if ( -x "./$executable" )
    {
        return "./$executable";
    }
    for my $dir ( split /:/, $ENV{PATH} )
    {
        $dir =~ s{/$}{};
        if ( -x "$dir/$executable" )
        {
            return "$dir/$executable";
        }
    }
    return;
}


###########################################################
# Runs a command in the local server and returns the result
###########################################################
sub get_local_result
{
    my ($cmd) = @_;

    my $result = qx($cmd);
    return unless $result;
    chomp $result;
    return $result;
}

my $user_values = {
    APPLICATION_PORT        => 9999,
    APPLICATION_PASSWORD    => 'private',
    APPLICATION_USER        => 'tungsten_testing',
    CONTINUENT_ROOT         => '/opt/continuent/cookbook_test',
};

my $evaluator_pid = start_evaluator($user_values);
if ($evaluator_pid)
{
    print "Evaluator started with pid $evaluator_pid\n"; 
}
else
{
    die "Could not start the evaluator load\n";
}



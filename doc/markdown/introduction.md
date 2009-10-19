
**NOTE:** both the software and the manual are under heavy
development. Expect things to be incomplete or change.

Moa is a set of tools build around [GNU
make](http://www.gnu.org/software/make) \citep{Gnumake} that
facilitates the use of GNU make in bioinformatics data analysis.

GNU Make is developed to aid in compilation of software. Software
compilation usually involves the execution of many preprocessing,
compilation and linker steps, potentially with differing
parameters and interdepending of each other. 

Gnu make goes about a compilation process by describing what target
files are to be created, on what source files or libraries the build
is depending and how the target needs to be build. If a dependency
needs to be compiled before it can be used for the final target file,
its building process can be described as well (and so no). In big
projects, this might result in thousands of files that are processed
in the correct order. Moreover, Gnu Make is intelligent enough to
repeat only the affected part of the build process if one or a few
source files are changed.

The description that Gnu Make uses to execute software compilation is
called a Makefile. The syntax of a Makefile is not only flexible
enough to allow Gnu Make to be used with a wide variety of programming
languages, but it can be used to automate any series of commands (as
long as they can be executed from the command line). It is therefore a
good idea to use Gnu Make in bioinformatics projects (see: )

A bioinformatics analysis often takes the form of a set of
interdepending analyses, i.e..

...

Moa wraps a set of common bioinformatics tools as Makefiles. Using Moa
gives you a:

* A uniform interface; all Moa makefiles use a central library that
	provides a uniform, command line, interface to configuring and
	executing jobs. 

* An easy way to track and repeat a set of analyses. Using Moa makes
 the creation of organized analysis structures easy.

* Interaction; templates are designed to interact with each other and
  make it easy to build pipelines from these buliding blocks.

* Parallel execution; Gnu make facillitates parallel execution of
    jobs.
 
Apart from a set of template Makefiles, the Moa contains several other

* moaBase; a central library describing a number of central routines used by
	all Makefiles

* The "moa" helper script; a frontend to using Moa.

* Additional helper scripts; several of the template files require
	helper scripts that are part of the moa package.

* Couchdb interface; Moa is able to store information on each job in a
	couchdb. See chapter XX.

## Example session 

To really understand how to use Moa, and how easy it is to do so, a
sample session will be helpful. 

We'll start by creating directories to hold the data and analysis
structure:
 
    mkdir introduction
    cd introduction
    mkdir 10.download
    cd 10.download

We've created a directory called `sample` to store the complete
analysis structure. Within this directory we'll start to organize the
components of our sample analysis. Moa doesn't enforce a sequential
organizaiton of an analysis pipeline, but expects the user to do this
by using a logical directory structure. Hence, the directory
describing the first step - downloading data from NCBI - is prefixed
with a `10.`. Other, later steps will use higher numbers.

    mkdir 10.genome

In the `10.download` directory we repeat this; Create numbered
directories to enforce organization. We'll now go to the `10.genome`
directory and actually use Moa to download something from NCBI.

    cd 10.genome
    moa new getFromNcbi
	
The utility script `moa` is used in occasions where direct interaction
with GNU Make is not possible (yet). In this case the "moa" script
creates our first Moa makefile. Whenever there is a Moa makefile you
can type `make help`. Apart from some introduction, you'll get see
some targets and parameters.

Targets are things that a Moa makefile can do. You can use GNU Make to
execute one of these target by running `Make TARGET`. Each Moa
makefile usually has one main task (in this case, download data from
NCBI). That main task is alway executed by running Make without a
target defined (i.e. `make`). 

If you try to run `make` now, you'll get an error!. This is because
you haven't told Moa yet what you want to download. You can do that by
setting a few parameters. `make help` gives you an overview of all
parameters that you can set. Moa distinguishes between required and
optional parameters. Optional parameters can usually be guessed or are
set to reasonable default values. In the case of the "getFromNcbi"
Makefile, there are two parameters that really need to be set:
`ncbi_db` and `ncbi_query`. In this case, it is possible to discover
what these are by doing a query on the NCBI website and browse until
you have the page with data you're looking for. In this case, we will
are going to download a ***Lactobacillus*** genome from
[NCBI](http://www.ncbi.nlm.nih.gov/nuccore/NC_012214). Upon inspection
of the URL (`http://www.ncbi.nlm.nih.gov/nuccore/NC_012214`) it is
straightofrward identify the two parameters that need to be set:

    make set ncbi_db=nuccore
    make set ncbi_query=NC_004567

Executing these two commands do not appear to do anything. You can,
however, check what parameters are set by running:

    make show

You should now see:

    ncbi_db	nuccore
    ncbi_query	NC_004567
    gfn_sequence_name	
    jid	moa_getFromNcbi_10.genome_??????????
    project	

There are a few more parameters here, you can ignore all of these now,
execpt for "jid". A "jid", or "job id" is a unique name that will be
used to track information on this job. It is important, particularly
if you're creating big projects, to set this to an understandable,
descriptive, but short value (without spaces!!), so we'll run an
additional `make set`:

    make set jid=lactobacillus.genome

This job is set up and can be executed now by running:

    make

This generates quite a lot of output. If things go wrong, there is
probably a clue to why in the output. If the Moa job is successful,
the last line should be "Moa finished - Succes!". If you do an `ls`
you now see a `fasta` directory with one fasta file. This fasta file
contains the downloaded genome.

Good, nice, but not very exciting. We'll now start doing something
with this data. For example, we could map the results from a 454 run
against this genome. Lets download a dataset from [NCBI's short read
archive](http://www.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?):

    cd ..
    mkdir 20.454reads
    cd 20.454reads
	mkdir 10.download
	cd 10.download
    moa new lftp

Here we use a different template: lftp. We need to set a single
parameters (i.e. the location of the file to download). 

    make set lftp_url=ftp://ftp.ncbi.nlm.nih.gov/sra/static/SRX002/SRX002375/SRR011133.fastq.gz
    make set jid=lactobacillus.454.reads

again we can run `make` to download the data. After downloading we see
that an archive is downloaded. We have now two options - unpack it
manually or automate unpacking. We could do it manually. If the
project is a quick, one-off, this is probably not so bad. However, you
won't be able to completely rerun the analysis without having to think
what steps you did manually. Therefore, we'll now set something up to
also automate this. 

    cd ..
    mkdir 20.unpack
    cd 20.unpack
    moa new gather

The Moa "gather" template is probably not named very well. It's a very
flexible template that allows you to do many different things on a set
of input files (read the manual page). We'll set it up now to automate
the unpacking.

    make set g_input_dir=../10.download
    make set g_input_pattern=*.gz
   
These two lines define what files are used as input for the "gather"
step. The next parameter is a sed command that strips of the .gz
extension for the unpacked output file.

    make set g_name_sed='s/\.gz$//'

(Note that you must use ' quotes to prevent bash from expanding the $
sign as a variable!)

    make set g_process=`

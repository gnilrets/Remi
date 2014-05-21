# Remi - Ruby Extract Modify Integrate

**Purpose:** Remi is a Ruby-based ETL suite that is built to provide
an expressive data transformation language and facilitate the design,
definition, and implementation business rules and logic.

Note: Yes, the vision is quite long winded.  Mostly because at this
stage it's difficult to provide specifics, so a story will have to do
and be refined and simplified as we go.

**Vision Prelude:** ETL project development usually goes something
like this: An ETL developer, let's call him Jeff, is brought into a
room with a business data analyst, project manager, and executive
sponsor.  Jeff is given some data that the team just simply can't
function without.  Maybe that data is in the form of an Excel
spreadsheet (gasp!), or if Jeff is lucky, it's a well documented data
dictionary that comes with some 3rd-party data that the company has
purchased.  In the best of situations, the team works together to
define a set of *business rules* that must be followed in order to
correctly load the data into the existing warehouse.  However, for many
projects even this step is skipped and the ETL developer is just
expected to get the data loaded and have it load consistently every
day without error or issue.

So Jeff sits down and starts to build the ETL code.  He quickly
starts to find exceptions to the agreed-upon business rules: source
data that doesn't follow the documented formats, business scenarios
that weren't ever considered, and just damn dirty data.  For some of
these issues, Jeff takes the liberty of writing some ETL to do some of
the basic cleaning and handling of edge-cases.  If he's super-hero
diligent, some of those cleaning rules may even make it back into the
original business rule documentation, but usually the only place the
documentation lives is in the code itself.  Other cases he has to
bring back to the team, who are already getting impatient that their
data isn't ready yet.  Several meetings are called to discuss the
issues and project plans have to be revised and Gantt charts rebuilt.
The team starts to wonder what's wrong with their ETL developer, who
didn't conceive of all of the myriad of possible data quality issues
during the project planning steps before they had real data.

After several delays, the data is finally in the warehouse and nightly
data feeds are scheduled.  Everyone's happy, but they really need to
get started analyzing the data.  Two days later, some new data with
unexpected malformating is processed.  It breaks to the extent that no
data is loaded and Jeff has to rush to build in some quick fix while
the team starts freaking out over client expectations and how this
just can't happen.  No way that fix makes it into the documentation.
Two weeks later a small bug is discovered in the ETL code.  The
business rule was in the project documentation, but there was just one
small aspect of it that failed to be coded properly, maybe because the
original sample data didn't include a case like it.  Another two weeks
passes and the data analyst is again freaking out because there's this
whole sub-segment of the data that is wrong.  Turns out this is just
another bizarre business case that was never considered and no special
treatment was made to handle it in the ETL.  Fixing the issue without
breaking everything else requires some substantial refactoring and a
new rule is developed that doesn't make it into the documentation
either.

After a few months there's an ETL solution that is hanging together by
threads, prone to break when bugs are fixed, nobody trusts it, and the
only people who can answer questions about why the data behaves in a
certain way are those that can read the ETL code.

I believe there's a better way.

**Vision:** The sad state of affairs that is described above is far
too typical.  It's like the world of data integration has stayed a
decade or more behind the rest of the software development world.  I
want Remi to change that by making it easier to develop high quality,
test-driven, maintainable, and well documented ETL processes.

In the ideal vision of Remi's role, ETL development begins the same
way as described in the above scenario, with a discussion between ETL
developers and business users.  However, instead of diving in to
building out all of the minute details of the project before handling
any real data, we focus a lot of the upfront effort on data discovery.
A huge amount of data discovery goes on in the early stages of ETL
development that is often lost when the goal is just to get the known
business rules working correctly, which are inevitably incomplete or
inaccurate at the outset.  Good ETL development practice would do this
anyway, but maintaining a tight link between discovered data
structure, validations, and documentation requires a considerable
effort.

The idea behind agile ETL development is that we proceed by using
exploratory data analysis to *uncover* the business rules and the
myriad of exceptions that are inherent in the live data.  Those rules
then need to be discussed and refined with the business interests.  As
the data discovery phase proceeds, those business rules are encoded as
tests that must pass before any changes to the production ETL are
made.  Additionally, these business rules must be easily discoverable
and understood by those who understand what the data means, but don't
have a need to follow the intricacies of the the ETL code.

Much of what I'm describing above is known as Test or Behavior Driven
Development (*TDD*/*BDD*).  Remi will expand on those principles in
the area of data integration by promoting *Business Rule Driven
Development (BRDD)*.

The core functionality of an ETL tool includes the ability
to define, sort, merge, and aggregate data.  What is often lacking in
ETL tools is how the transformations represented by ETL code relate to
business logic.  In a fast-paced agile data environment, it is nearly
impossible to maintain business-user-level documentation that is
accurate, up-to-date, and comprehensible.  The goal of Remi is to
provide all of the core functionality of a solid ETL tool while also
borrowing from Test and Behavior Driven Development methodologies to
make it possible to maintain a tight link between the actual ETL code
and the realities of rapidly changing business rules.  I'll refer to
this concept as *Business Rule Driven Development (BRDD)*.

While the details of a BRDD spec still need to be ironed out, let's
consider an example to highlight the idea.

````ruby
input_record = []blork
expected_output_record = []

define record_level rule "" do
  describe ""
end

actual_output_record
...
actual_output_record.should eq expected_output_record
````

[fluffy version](/doc/vision_a_story.md)

**Status:** Right now the focus is mostly on refining the basic ETL
structure in how Remi will define, sort, merge, and aggregate data.
Once this basic functionality has been established and demonstrated to
have performance on par for production work, BRDD development can begin.

I intend to follow [semantic versioning](http://semver.org/)
principles.  But of course, while we're still on major version zero,
no attempt will be made to maintain backward compatibility.


## Installation

So, this will eventually be packaged as a gem with a tool to set up
standard Remi projects, but for now we're only testing, so just

    bundle install

and go!

## Usage Overview

Data in Remi is stored in *Datasets*.  A dataset is an ordered
collection of values of data organized by variables.

Typically, datasets occupy
physical space on a drive, although they might eventually be
abstracted to enable support for in-memory or in-database datasets
that use a common API.  *Datasets* are contained in a *Data Library*
that may be a directory in a file system, a database/schema on a
database server, or just some partitioned space in memory.  A
*Datastep* is an operation on a *Dataset* that involves transforming.

### Libraries

probably should be doing libname[:dataset] to be more ruby-natural

### Creating data

### Viewing data

### Reading data

### Importing from CSV

### Sorting

### Merging

### Aggregating

## Contributing

Fork, code, pull request.  Try to follow the
[Ruby style guide](https://github.com/styleguide/ruby).

## About

Remi was conceived during the paternity time I took off work to care
for my son during his first week of life, whose name is not
coincidentally also Remi.  While I suppose a better father would have
had nothing to do other than dote and oogle over their new baby, the
fact of the matter is that newborns are just plain boring.  Other than
making sure they're snuggled and their mothers get enough sleep,
there's not much to do but stare and them and think.  So I found
myself daydreaming a lot about my job and what I can do to fix my
least favorite parts of it.

I started doing ETL work about five years prior to Remi when I worked
in the analytics unit of a health insurance company.  We used a
dinosaur of a language called SAS to transform claim data into
business-reportable cubes.  Despite it being a language that was
clearly showing its age, it was still fairly expressive and
facilitated writing fast and complex ETL code.  I ended up getting
pretty good at SAS, and the warehouse I helped build supported the
company's core analytics efforts.  But then I got fed up with the
bureaucracy, politics, and apathy of working for large old fashioned
company and decided to join a startup that prided themselves on
cloud-based open source technology.

At first I felt very lost without SAS, but with the cost of a license
being roughly $5,000/year, all of my SAS-specific knowledge was pretty
worthless.  It was hard to find alternative open source tools that
made it quick and easy to visualize data for the purposes of data
transformation and integration.  Sure, there's R, but while learning
it, I very quickly started running into the memory limits and the
community packages to work around the issue felt very cumbersome.

My new company had chosen to go with Pentaho's Kettle for their ETL
solution.  At first, I rather liked it.  It was nice to see data
transformations laid out visually, and it was a snap to bring in new
data sources.  Of course, the problem with GUI-based programming is
that if the developers didn't think of including something in the
package, you're pretty much SOL.  It's also next-to-impossible to
design modular, test-driven, and flexible ETL using Kettle (if you
disagree, I'd love to see examples).  Despite our best efforts, our
Kettle code base became very difficult to manage due to a large amount
of mostly-but-not-quite-duplicated code.  Transformations would
frequently break when we fixed some seemingly-unrelated bugs.  Not to
mention the fact that the transformations we built would quickly drift
away from any business rules documentation, assuming they even
existed.

I wanted an ETL system that offered the expressiveness of a procedural
ETL solution like SAS, but also facilitated more modern coding
standards and conventions.  I had recently been exposed to Ruby
through some DevOps Chef projects I was working on and just fell in
love with it.  So, I started building out the core functionality of
Remi during those first few weeks of staying up late with Remi crying
and sleeping in 15 minute sprints.

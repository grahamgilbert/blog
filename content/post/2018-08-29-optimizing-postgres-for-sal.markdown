---
categories:
  - Sal
  - Postgres
date: "2018-08-29T11:50:53Z"
title: Optimizing Postgres for Sal
---

Over time, you may notice your [Sal](https://github.com/salopensource/sal) install getting slower and slower - this will happen faster the more devices you have checking in. You may even see rediciulous amounts of disk space being used - maybe even 1Gb per hour. This can all be solved by tweaking some simple matinenance settings on your Postgres server.

## Background

Before we crack on with how to stop this from happening, it will be useful to know how Postgres handles deleted data.

Take the following table (this is a representation of the `facts` table in Sal):

```
id | machine_id | fact_name | fact_data
---------------------------------------
01 | 01         | os_vers   | 10.13.6
02 | 02         | os_vers   | 10.13.6
03 | 01         | memory    | 16Gb
04 | 02         | memory    | 4Gb
```

When a device checks into Sal, rather than asking the database what facts are stored for the machine, iterating over each one, working out which ones have values that need updating, working out which ones are missing, and working out which ones need to be removed, Sal instructs the database to delete all of the facts for that device, and then to save the new ones. What could potentially be 1000 operations becomes two, which is much faster.

You would expect Postgres to delete the rows out of the database at this point. Unfortunately that isn't what happens. What actually happens is Postgres marks the row as able to be deleted. There are various good reasons for this outlined in the [documentation](https://www.postgresql.org/docs/current/static/routine-vacuuming.html) which I won't go into here, but when an application like Sal is updating and deleting data constantly, the disk usage can skyrocket.

```Database after machine_id 01 has checked in
id | machine_id | fact_name | fact_data
---------------------------------------
XX | XX         | XXXXXXX   | XXXXXXX
02 | 02         | os_vers   | 10.13.6
XX | XX         | XXXXXX    | XXXXXXX
04 | 02         | memory    | 4Gb
05 | 01         | os_vers   | 10.13.6
06 | 01         | memory    | 16Gb
```

As time goes on, these empty tuples will mount up. This is where the database's maintenance tasks come in. They are supposed to come along and vaccuum the tables, removing these dead tuples.

## So what can we do?

But unfortunately the defaults are basically useless. I am not going to go in depth about why I chose the following settings - I learned a lot from [this post](https://blog.2ndquadrant.com/autovacuum-tuning-basics/) and adjusted their recommendations to meet our needs. My Postgres server is Amazon's RDS, so the settings are entered in the Parameter Group for the database. If you are running a bare metal install, you will be editing the Postgres configuration. I have added a few notes about why we chose the value we did next to the setting. Our general goal was to have maintenance performed more frequently, so it would take less time as it will have less work to do during each run, and to give the maintenance worker as much resources as possible so it would complete as quickly as possible.

```bash
autovacuum_analyze_scale_factor = 0.01
# This means the 1% of the table needs to change to trigger autovacuum.

autovacuum_max_workers = 1
# The default is 3. We set this to 1 to allow maximum resources for each worker, so it can complete it's work quickly and move onto the next table.

autovacuum_naptime = 30
# The delay between autovacuum runs in seconds. This is half the default - we want autovacuum to run as often as possible.

autovacuum_vacuum_cost_limit = 10000
# The 'cost' of autovacuuming is calculated using several factors (see the article linked for a good explanation) - we want autovacuum to happen as much as possible, so this is high.

autovacuum_vacuum_scale_factor = 0.1
# % of dead tuples to tolerate before triggering an autovacuum

maintenance_work_mem = 10485760
# The amount of memory to assign to mantinenance in Kb. We have assigned ~10Gb, as we have lots of memory on our RDS instance and can spare it. It should be set to the maximum amount of memory you can spare, as the maintenance will run much quicker if it can load more of the table into memory rather than having to read it from disk every time.
```

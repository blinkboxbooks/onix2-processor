# Change log

## Open Source release (2015-01-28 14:11:21)

Today we have decided to publish parts of our codebase on Github under the [MIT licence](LICENCE). The licence is very permissive, but we will always appreciate hearing if and where our work is used!

## 0.3.0 ([#8](https://git.mobcastdev.com/Marvin/onix2-processor/pull/8) 2015-01-27 18:08:52)

Docker

### New feature

- Add docker components

## 0.2.3 ([#7](https://git.mobcastdev.com/Marvin/onix2-processor/pull/7) 2015-01-14 16:34:05)

Update gems

### Improvements

- Ensure we log common mapping events
- Update gems.

## 0.2.2 ([#6](https://git.mobcastdev.com/Marvin/onix2-processor/pull/6) 2015-01-09 15:30:36)

Ensure message_id_chain is optional

### Bugfix

- Test messages don't have message_ids (because they're not sent from another service), this no longer breaks the service. 

## 0.2.1 ([#5](https://git.mobcastdev.com/Marvin/onix2-processor/pull/5) 2015-01-07 17:47:38)

Common Mapping return value

### Bugfix 

- Messages aren't being correctly acknowledged because of a bug in the common mapping library. This is now fixed.

## 0.2.0 ([#4](https://git.mobcastdev.com/Marvin/onix2-processor/pull/4) 2015-01-07 16:11:10)

Mapping & Prizes

### New feature

- Uses the real mapping gem
- Has a command line tool for viewing the processed result of an ONIX file (super handy for investigations)
- Can now extract prizes from ONIX

## 0.1.2 ([#3](https://git.mobcastdev.com/Marvin/onix2-processor/pull/3) 2014-12-22 16:38:37)

Logging to graylog; upgrade gems

### Improvements

- Upgrade version of gems so Bunny logs to Graylog

## 0.1.1 ([#2](https://git.mobcastdev.com/Marvin/onix2-processor/pull/2) 2014-11-21 16:45:24)

Crappy CDATA tags

### Improvements

- Deal with crappy CDATA tags in Publisher names.

## 0.1.0 ([#1](https://git.mobcastdev.com/Marvin/onix2-processor/pull/1) 2014-11-12 13:26:41)

First release of the ONIX 2 processor in Marvin 2

### New Features

- Sends `ingestion.file.rejected.v2` messages with reasons for ONIX files in which invalid ONIX metadata has been found.
- Collects related books' ISBNs
- Extracts publisher contributor IDs for additional name-clash correlation in magrathea.
- Bug fixes, code extensions & more & deeper unit tests.


# Change log

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


# Change log

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


# ONIX2 Processor

Creates a book metadata document from each Product entry in an [ONIX 2.1]() document.

## Functionality

This service will create a queue that binds to the **Marvin** exchange and will collect all messages which have `Content-Type: application/vnd.blinkbox.books.ingestion.file.pending.v2+json` and `Referenced-Content-Type: application/onix2+xml` (these would normally be sent by the [Watcher]()).

Each of these inbound messages contains a _token_ (a reference to a file previously stored by the [Storage Service]()) which is translated to a downloadable URL, retrieved and processed, creating a book metadata record for each book referenced in the ONIX document.

Every book metadata record is pushed onto the _Marvin_ exchange as an `application/vnd.blinkbox.books.ingestion.book.metadata.v2+json` document, which will be picked up by [Magrathea]() and stored for content audits, delivery to shop and so on.

## Requirements

This service is designed to run in a blinkbox Books _Marvin_ ingestion environment, as such it both requires other services to run and only has directly useful output when paired with the rest of a _Marvin_ deployment.

Please check out the [Marvin readme]() for more information on how a _Marvin_ environment hangs together.

This service requires:

* A [Storage Service]() to retrieve data from
* A RabbitMQ instance with:
    * a **Marvin** headers exchange
    * a **Mapping** headers exchange
* (Optional) a Graylog instance for sending log messages to

## Notes

* There is a helpful application - `bin/onix2bbb` - which will output human readable YAML representations of book metadata stored in an ONIX file.

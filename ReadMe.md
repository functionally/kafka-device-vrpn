VRPN events via a Kafka message broker
=============================================

This package contains functions for passing [VRPN](https://github.com/vrpn/vrpn/wiki) events to topics on a [Kafka message broker](https://kafka.apache.org/).


Clients
-------

The simple Kafka client that produces events from VRPN can be run, for example, as follows:

	cabal run kafka-device-vrpn -- device@localhost vrpn-client localhost 9092 events vrpn


Also see https://hackage.haskell.org/package/kafka-device/.

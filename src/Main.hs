{-|
Module      :  Main
Copyright   :  (c) 2016-17 Brian W Bush
License     :  MIT
Maintainer  :  Brian W Bush <consult@brianwbush.info>
Stability   :  Experimental
Portability :  Stable

Simple producer of VRPN \<<https://github.com/vrpn/vrpn/wiki>\> events to a Kafka topic.
-}


module Main (
-- * Main entry
  main
) where


import Network.UI.Kafka (TopicConnection(TopicConnection))
import Network.UI.Kafka.VRPN (vrpnLoop)
import System.Environment (getArgs)


-- | The main action.
main :: IO ()
main =
  do
    args <- getArgs
    case args of
      [device, client, host, port, topic, sensor] ->
        do
          let
            callbacks = [minBound..maxBound]
          putStrLn $ "VRPN device:    " ++ device
          putStrLn $ "Kafka client:   " ++ client
          putStrLn $ "Kafka address:  (" ++ host ++ "," ++ port ++ ")"
          putStrLn $ "Kafka topic:    " ++ topic
          putStrLn $ "Sensor name:    " ++ sensor
          putStrLn $ "GLUT callbacks: " ++ show callbacks
          (_, loop) <-
            vrpnLoop
              device
              (TopicConnection client (host, read port) topic)
              sensor
              callbacks
          result <- loop
          either print return result
      _ -> putStrLn "USAGE: kafka-device-vrpn device client host port topic senosr"

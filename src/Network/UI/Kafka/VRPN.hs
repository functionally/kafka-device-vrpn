{-|
Module      :  Network.UI.Kafka.VRPN
Copyright   :  (c) 2016 Brian W Bush
License     :  MIT
Maintainer  :  Brian W Bush <consult@brianwbush.info>
Stability   :  Experimental
Portability :  Stable

Produce events on a Kafka topic from VRPN \<<https://github.com/vrpn/vrpn/wiki>\> events.
-}


module Network.UI.Kafka.VRPN (
-- * Event loop
  vrpnLoop
) where


import Network.Kafka (KafkaAddress, KafkaClientId)
import Network.Kafka.Protocol (TopicName)
import Network.UI.Kafka (ExitAction, LoopAction, Sensor, producerLoop)
import Network.UI.Kafka.Types (Event(..))
import Network.VRPN


vrpnLoop :: String -> KafkaClientId -> KafkaAddress -> TopicName -> Sensor -> IO (ExitAction, LoopAction)
vrpnLoop = undefined

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

import qualified Network.VRPN as V


data VrpnCallback =
    Tracker
  | Button
  | Analog
  | Dial
    deriving (Bounded, Enum, Eq, Ord, Read, Show)


vrpnLoop :: String -> KafkaClientId -> KafkaAddress -> TopicName -> Sensor -> [VrpnCallbacks] -> IO (ExitAction, LoopAction)
vrpnLoop device client address topic sensor callback s=
  do
    nextEvent <- newEmptyMVar
    devices <-
      mapM V.openDevice
        $ filter ((`elem` callbacks) . fst)
        [
          (Tracker, V.Tracker device (Just $ positionCallback nextEvent) Nothing Nothing)
        , (Button , V.Button  device (Just $ buttonCallback   nextEvent)                )
        , (Analog , V.Analog  device (Just $ analogCallback   nextEvent)                )
        , (Dial   , V.Dial    device (Just $ dialCallback     nextEvent)                )
        ]
    undefined


positionCallback :: MVar Event -> V.PositionCallback
positionCallback nextEvent _ s (px, py, pz) (ox, oy, oz) =
  undefined


buttonCallback :: MVar Event -> V.ButtonCallback
buttonCallback nextEvent _ s :qa


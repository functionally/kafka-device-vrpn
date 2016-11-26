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


import Control.Concurrent (MVar, forkIO, isEmptyMVar, newEmptyMVar, putMVar, takeMVar)
import Control.Monad (void, zipWithM_)
import Network.Kafka (KafkaAddress, KafkaClientId)
import Network.Kafka.Protocol (TopicName)
import Network.UI.Kafka (ExitAction, LoopAction, Sensor, producerLoop)
import Network.UI.Kafka.Types (Button(..), Event(..))

import qualified Network.VRPN as V


-- | Types of VRPN callbacks.  See \<<https://hackage.haskell.org/package/vrpn/docs/Network-VRPN.html>\> for more details.
data VrpnCallback =
    -- | Change in tracker state.
    Tracker
  | -- | Change in button state.
    Button
  | -- | Change in analog axis state.
    Analog
  | -- | Change in dial state.
    Dial
    deriving (Bounded, Enum, Eq, Ord, Read, Show)


-- | Produce events for a Kafka topic from VRPN callbacks \<<https://hackage.haskell.org/package/vrpn/docs/Network-VRPN.html>\>.
vrpnLoop :: String                      -- ^ The VRPN host, e.g. spacenav0@localhost.
         -> KafkaClientId               -- ^ A Kafka client identifier for the producer.
         -> KafkaAddress                -- ^ The address of the Kafka broker.
         -> TopicName                   -- ^ The Kafka topic name.
         -> Sensor                      -- ^ The name of the sensor producing events.
         -> [VrpnCallback]              -- ^ Which callbacks to enable.
         -> IO (ExitAction, LoopAction) -- ^ Action to create the exit and loop actions.
vrpnLoop device clientId address topic sensor callbacks =
  do
    exitNow <- newEmptyMVar
    nextEvent <- newEmptyMVar
    devices <-
      mapM (V.openDevice . snd)
        $ filter ((`elem` callbacks) . fst)
        [
          (Tracker, V.Tracker device (Just $ positionCallback nextEvent) Nothing Nothing)
        , (Button , V.Button  device (Just $ buttonCallback   nextEvent)                )
        , (Analog , V.Analog  device (Just $ analogCallback   nextEvent)                )
        , (Dial   , V.Dial    device (Just $ dialCallback     nextEvent)                )
        ]
    (exit, loop) <-
      producerLoop clientId address topic sensor
      $ (: [])
      <$> takeMVar nextEvent
    return
      (
        do
          putMVar exitNow ()
          exit
      , do
          void
            . forkIO
            $ V.mainLoops (not <$> isEmptyMVar exitNow) (1 :: Double) devices
          loop
      )


-- | Translate VRPN position state change to events.
positionCallback :: MVar Event                    -- ^ Reference to the next event.
                 -> V.PositionCallback Int Double -- ^ The VRPN callback.
positionCallback nextEvent _ _ p o =
  do
    putMVar nextEvent
      $ LocationEvent p
    putMVar nextEvent
      $ OrientationEvent o


-- | Translate VRPN button state change to events. 
buttonCallback :: MVar Event           -- ^ Reference to the next event.
               -> V.ButtonCallback Int -- ^ The VRPN callback.
buttonCallback nextEvent _ i x =
  putMVar nextEvent
    $ ButtonEvent (IndexButton i, toEnum $ fromEnum $ not x) 


-- | Translate VRPN analog state change to events.
analogCallback :: MVar Event              -- ^ Reference to the next event.
               -> V.AnalogCallback Double -- ^ The VRPN callback.
analogCallback nextEvent _ =
  zipWithM_
    ((putMVar nextEvent .) . AnalogEvent)
    [0..]


-- | Translate VRPN dial state change to events.
dialCallback :: MVar Event                -- ^ Reference to the next event.
             -> V.DialCallback Int Double -- ^ The VRPN callback.
dialCallback nextEvent _ i x =
  putMVar nextEvent
    $ DialEvent i x


{-# LANGUAGE ConstraintKinds            #-}
{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE DeriveFoldable             #-}
{-# LANGUAGE DeriveFunctor              #-}
{-# LANGUAGE DeriveTraversable          #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TypeFamilies               #-}

-------------------------------------------------------------------------------------
-- |
-- Copyright   : (c) Hans Hoglund 2012-2014
--
-- License     : BSD-style
--
-- Maintainer  : hans@hanshoglund.se
-- Stability   : experimental
-- Portability : non-portable (TF,GNTD)
--
-- Provides tempo meta-data.
--
-- /Warning/ This is not supported by any backends yet.
--
-------------------------------------------------------------------------------------

module Music.Score.Meta.Pickup (
        -- * Pickup type
        Pickup,
        
        -- TODO

  ) where


import           Control.Lens              (view)
import           Control.Monad.Plus
import           Data.Foldable             (Foldable)
import qualified Data.Foldable             as F
import qualified Data.List                 as List
import           Data.Map                  (Map)
import qualified Data.Map                  as Map
import           Data.Maybe
import           Data.Semigroup
import           Data.Set                  (Set)
import qualified Data.Set                  as Set
import           Data.String
import           Data.Traversable          (Traversable)
import qualified Data.Traversable          as T
import           Data.Typeable

import           Music.Pitch.Literal
import           Music.Score.Meta
import           Music.Score.Part
import           Music.Score.Pitch
import           Music.Score.Internal.Util
import           Music.Time
import           Music.Time.Reactive

-- | Represents a rehearsal mark.
--
-- TODO this needs zero-duration spans to work properly.
data Pickup = Pickup (Maybe String) Int
    deriving (Eq, Ord, Typeable)
-- name level(0=standard)

{-
instance Default Pickup where
    def = Pickup Nothing 0
-}

instance Semigroup Pickup where
    Pickup n1 l1 <> Pickup n2 l2 = Pickup (n1 <> n2) (l1 `max` l2)

instance Monoid Pickup where
    mempty  = Pickup Nothing 0
    mappend = (<>)

instance Show Pickup where
    show (Pickup name level) = "A" -- TODo


-- metronome :: Duration -> Bpm -> Tempo
-- metronome noteVal bpm = Tempo Nothing (Just noteVal) $ 60 / (bpm * noteVal)

rehearsalMark :: (HasMeta a, HasPosition a) => Pickup -> a -> a
rehearsalMark c x = rehearsalMarkDuring (_era x) c x

rehearsalMarkDuring :: HasMeta a => Span -> Pickup -> a -> a
rehearsalMarkDuring s x = addMetaNote $ view event (s, x)

withPickup :: (Pickup -> Score a -> Score a) -> Score a -> Score a
withPickup = withMeta


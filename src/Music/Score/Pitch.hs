
{-# LANGUAGE
    TypeFamilies,
    DeriveFunctor,
    DeriveFoldable,
    DeriveDataTypeable,
    FlexibleInstances,
    FlexibleContexts,
    ConstraintKinds,
    GeneralizedNewtypeDeriving #-}

-------------------------------------------------------------------------------------
-- |
-- Copyright   : (c) Hans Hoglund 2012
--
-- License     : BSD-style
--
-- Maintainer  : hans@hanshoglund.se
-- Stability   : experimental
-- Portability : non-portable (TF,GNTD)
--
-- Provides functions for manipulating pitch.
--
-------------------------------------------------------------------------------------


module Music.Score.Pitch (     
        -- * Pitch representation
        HasPitch(..),
        Interval,  
        HasPitch',
        PitchT(..),
        -- getPitches,
        -- setPitches,
        -- modifyPitches,

        -- * Pitch transformations
        -- ** Transposition
        up,
        down,
        invertAround,
        octavesUp,
        octavesDown,
  ) where

import Control.Monad (ap, mfilter, join, liftM, MonadPlus(..))
import Data.String
import Data.Typeable
import Data.Traversable
import qualified Data.List as List
import Data.VectorSpace
import Data.AffineSpace
import Data.Ratio

import Music.Pitch.Literal

class HasPitch a where

    -- | Associated pitch type. Should normally implement 'Ord', 'Show' and 'AffineSpace'.
    type Pitch a :: *

    -- |
    -- Get the pitches of the given value.
    --
    getPitches :: a -> [Pitch a]

    -- |
    -- Set the pitch of the given value.
    --
    setPitch :: Pitch a -> a -> a

    -- |
    -- Modify the pitch of the given value.
    --
    modifyPitch :: (Pitch a -> Pitch a) -> a -> a

    setPitch n = modifyPitch (const n)
    modifyPitch f x = x

type Interval a = Diff (Pitch a)

type HasPitch' a = (
    HasPitch a, 
    VectorSpace (Interval a), Integer ~ Scalar (Interval a),
    AffineSpace (Pitch a)
    )

newtype PitchT p a = PitchT { getPitchT :: (p, a) }
    deriving (Eq, Ord, Show, Functor)

instance HasPitch (PitchT p a) where
    type Pitch (PitchT p a) = p
    getPitches (PitchT (v,_))    = [v]
    modifyPitch f (PitchT (v,x)) = PitchT (f v, x)

instance HasPitch ()                        where { type Pitch ()         = ()        ; getPitches = return; modifyPitch = id }
instance HasPitch Double                    where { type Pitch Double     = Double    ; getPitches = return; modifyPitch = id }
instance HasPitch Float                     where { type Pitch Float      = Float     ; getPitches = return; modifyPitch = id }
instance HasPitch Int                       where { type Pitch Int        = Int       ; getPitches = return; modifyPitch = id }
instance HasPitch Integer                   where { type Pitch Integer    = Integer   ; getPitches = return; modifyPitch = id }
instance Integral a => HasPitch (Ratio a)   where { type Pitch (Ratio a)  = (Ratio a) ; getPitches = return; modifyPitch = id }

instance HasPitch a => HasPitch (a,b) where
    type Pitch (a,b)  = Pitch a
    getPitches (a,b)    = getPitches a
    modifyPitch f (a,b) = (modifyPitch f a,b)

instance HasPitch a => HasPitch [a] where
    type Pitch [a] = Pitch a
    getPitches []    = error "getPitch: Empty list"
    getPitches as    = concatMap getPitches as
    modifyPitch f    = fmap (modifyPitch f)
    
-- |
-- Transpose up.
--
-- > Interval -> Score a -> Score a
--
up :: (HasPitch a, AffineSpace p, p ~ Pitch a) => Interval a -> a -> a
up a = modifyPitch (.+^ a)

-- |
-- Transpose down.
--
-- > Interval -> Score a -> Score a
--
down :: (HasPitch a, AffineSpace p, p ~ Pitch a) => Interval a -> a -> a
down a = modifyPitch (.-^ a)

-- |
-- Invert around the given pitch.
--
-- > Pitch -> Score a -> Score a
--
invertAround :: (AffineSpace (Pitch a), HasPitch a) => Pitch a -> a -> a
invertAround basePitch a = modifyPitch ((basePitch .+^) . negateV . (.-. basePitch)) a

-- |
-- Transpose up by the given number of octaves.
--
-- > Integer -> Score a -> Score a
--
octavesUp       :: (HasPitch' a, IsInterval (Interval a)) => 
                Integer -> a -> a

-- |
-- Transpose down by the given number of octaves.
--
-- > Integer -> Score a -> Score a
--
octavesDown     :: (HasPitch' a, IsInterval (Interval a)) => 
                Integer -> a -> a

octavesUp a     = up (_P8^*a)
octavesDown a   = down (_P8^*a)


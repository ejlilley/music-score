
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

import Data.Set(Set)
import Data.Map(Map)
import Data.Foldable (toList)
import Data.Maybe (listToMaybe)
import Control.Monad (join)


class HasFoo a where
    type Foo a
    type UnFoo a b
    getFoo    :: a -> Foo a
    setFoo    :: (b ~ (UnFoo a (Foo b))) => Foo b -> a -> b
    modifyFoo :: (b ~ (UnFoo a (Foo b))) => (Foo a -> Foo b) -> a -> b

class HasBar a where
    type Bar a
    type UnBar a b
    getBar    :: a -> Bar a
    setBar    :: (b ~ (UnBar a (Bar b))) => Bar b -> a -> b
    modifyBar :: (b ~ (UnBar a (Bar b))) => (Bar a -> Bar b) -> a -> b


data FooT f a = FooT f a

instance HasFoo (FooT f a) where
    type Foo   (FooT f a)    = f
    type UnFoo (FooT f a) g  = FooT g a
    getFoo (FooT f _)       = f
    setFoo f (FooT _ x)     = FooT f x 
    modifyFoo g (FooT f x)  = FooT (g f) x

instance HasFoo a => HasFoo [a] where
    type Foo [a] = Foo a
    type UnFoo [a] g = [UnFoo a g]
    getFoo = getFoo . head
    setFoo x = fmap (setFoo x)
    modifyFoo g = fmap (modifyFoo g)

instance HasFoo a => HasFoo (Map k a) where
    type Foo (Map k a) = Foo a
    type UnFoo (Map k a) g = Map k (UnFoo a g)
    getFoo = getFoo . head . toList
    setFoo x = fmap (setFoo x)
    modifyFoo g = fmap (modifyFoo g)




data BarT f a = BarT f a

instance HasBar (BarT f a) where
    type Bar   (BarT f a)    = f
    type UnBar (BarT f a) g  = BarT g a
    getBar (BarT f _)       = f
    setBar f (BarT _ x)     = BarT f x 
    modifyBar g (BarT f x)  = BarT (g f) x

instance HasBar a => HasBar [a] where
    type Bar [a] = Bar a
    type UnBar [a] g = [UnBar a g]
    getBar = getBar . head
    setBar x = fmap (setBar x)
    modifyBar g = fmap (modifyBar g)

instance HasBar a => HasBar (Map k a) where
    type Bar (Map k a) = Bar a
    type UnBar (Map k a) g = Map k (UnBar a g)
    getBar = getBar . head . toList
    setBar x = fmap (setBar x)
    modifyBar g = fmap (modifyBar g)





-- Cross-instances
instance HasFoo a => HasFoo (BarT b a) where
    type Foo (BarT b a) = Foo a
    type UnFoo (BarT b a) c = BarT b (UnFoo a c)
    getFoo (BarT _ x) = getFoo x
    setFoo f (BarT b x) = BarT b (setFoo f x)
    modifyFoo f (BarT b x) = BarT b (modifyFoo f x)

instance HasBar a => HasBar (FooT b a) where
    type Bar (FooT b a) = Bar a
    type UnBar (FooT b a) c = FooT b (UnBar a c)
    getBar (FooT _ x) = getBar x
    setBar f (FooT b x) = FooT b (setBar f x)
    modifyBar f (FooT b x) = FooT b (modifyBar f x)



   
-- class HasFoo a where
--     type Foo a
--     getFoo    :: a -> Maybe (Foo a)
--     setFoo    :: (b ~ (a /~ Foo b)) => Foo b -> a -> b
--     modifyFoo :: (b ~ (a /~ Foo b)) => (Foo a -> Foo b) -> a -> b
--     setFoo x      = modifyFoo (const x)
--     -- modifyFoo f x = setFoo (maybe undefined f $ getFoo x) x




-- 
-- import Data.Set(Set)
-- import Data.Map(Map)
-- import Data.Foldable (toList)
-- import Data.Maybe (listToMaybe)
-- import Control.Monad (join)
-- 
-- type family a /~ b
-- 
-- type instance [a]       /~ g    = [a /~ g]
-- type instance (Set a)   /~ g    = Set (a /~ g)
-- type instance (Map k a) /~ g    = Map k (a /~ g)
-- type instance (b -> a)  /~ g    = b -> (a /~ g)
-- type instance (b, a)    /~ g    = (b, a /~ g)
-- 
-- class HasFoo a where
--     type Foo a
--     getFoo    :: a -> Maybe (Foo a)
--     setFoo    :: (b ~ (a /~ Foo b)) => Foo b -> a -> b
--     modifyFoo :: (b ~ (a /~ Foo b)) => (Foo a -> Foo b) -> a -> b
--     setFoo x      = modifyFoo (const x)
--     -- modifyFoo f x = setFoo (maybe undefined f $ getFoo x) x
-- 
-- -- modifyFoo' :: (Foo a -> Foo a) -> a -> a
-- -- modifyFoo' = modifyFoo
-- 
-- 
-- data FooT f a = FooT f a
-- type instance (FooT f a) /~ g = FooT g a
-- instance HasFoo (FooT f a) where
--     type Foo (FooT f a)     = f
--     getFoo (FooT f _)       = Just f
--     modifyFoo g (FooT f x)  = FooT (g f) x
-- 
-- 
-- instance HasFoo a => HasFoo [a] where
--     type Foo [a] = Foo a
--     getFoo = join . fmap getFoo . listToMaybe
--     modifyFoo g = fmap (modifyFoo g)
-- 
-- instance HasFoo a => HasFoo (Map k a) where
--     type Foo (Map k a) = Foo a
--     getFoo = getFoo . toList
--     modifyFoo g = fmap (modifyFoo g)
-- 
-- 
-- 
-- 
-- class HasBar a where
--     type Bar a
--     getBar    :: a -> Maybe (Bar a)
--     setBar    :: (b ~ (a /~ Bar b)) => Bar b -> a -> b
--     modifyBar :: (b ~ (a /~ Bar b)) => (Bar a -> Bar b) -> a -> b
--     setBar x      = modifyBar (const x)
--     -- modifyBar f x = setBar (f $ getBar x) x
-- 
-- 
-- data BarT f a = BarT f a
-- type instance (BarT f a) /~ g = BarT g a
-- instance HasBar (BarT f a) where
--     type Bar (BarT f a)     = f
--     getBar (BarT f _)       = Just f
--     modifyBar g (BarT f x)  = BarT (g f) x
-- 
-- 
-- instance HasBar a => HasBar [a] where
--     type Bar [a] = Bar a
--     getBar = join . fmap getBar . listToMaybe
--     modifyBar g = fmap (modifyBar g)
--     
-- 
--                                              
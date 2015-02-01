module TestMain where

import Test.QuickCheck
import Test.QuickCheck.Gen

main = do
  quickCheck $ \n -> n + 1 == 1 + n

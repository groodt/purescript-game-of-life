module Life where

import Debug.Trace

import Data.Tuple
import Data.Array
import Data.Foldable

import Control.MonadPlus

import Data.Date

-- Pure code 
-------------

gridWidth :: Number
gridWidth = 25

cellWidthPx :: Number
cellWidthPx = 10

gridWidthPx :: Number
gridWidthPx = gridWidth * cellWidthPx

type Pos = Tuple Number Number

type Board = [Pos]

glider :: Board
glider = [Tuple 4 2, Tuple 2 3, Tuple 4 3, Tuple 3 4, Tuple 4 4]

rPentomino :: Board
rPentomino = [Tuple 3 2, Tuple 4 2, Tuple 2 3, Tuple 3 3, Tuple 3 4]

isAlive :: Board -> Pos -> Boolean
isAlive b p = elem p b

isEmpty :: Board -> Pos -> Boolean
isEmpty b p = not (isAlive b p)

neighbs :: Pos -> [Pos]
neighbs (Tuple x y) = map wrap [Tuple (x - 1) (y - 1), Tuple x (y - 1),
                            Tuple (x + 1) (y - 1), Tuple (x - 1) y,
                            Tuple (x + 1) y, Tuple (x - 1) (y + 1),
                            Tuple x (y + 1), Tuple (x + 1) (y + 1)]

wrap :: Pos -> Pos
wrap (Tuple x y) = Tuple (((x - 1) % gridWidth) + 1) (((y - 1) % gridWidth) + 1)

liveneighbs :: Board -> Pos -> Number
liveneighbs b = length <<< filter (isAlive b) <<< neighbs

survivors :: Board -> [Pos]
survivors b = do
                p <- b
                guard $ elem (liveneighbs b p) [2, 3]
                return p

births :: Board -> [Pos]
births b = do
              p <- rmdups (concat (map neighbs b))
              guard $ isEmpty b p
              guard $ liveneighbs b p == 3
              return p

rmdups :: forall a. (Eq a) => [a] -> [a]
rmdups [] = []
rmdups (x : xs) = x : (rmdups (filter ((/=) x) xs))

nextgen :: Board -> Board
nextgen b = survivors b ++ births b

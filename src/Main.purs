module Main where

import Debug.Trace

import Data.Tuple
import Data.Array
import Data.Foldable

import Control.MonadPlus
import Control.Monad.Eff
import Control.RAF

import Graphics.Canvas (getCanvasElementById, getContext2D)
import Graphics.Canvas.Free

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


-- Rendering code
-----------------

type PosPx = Tuple Number Number

backgroundColourHex :: String
backgroundColourHex = "#FFFFFF"

foregroundColourHex :: String
foregroundColourHex = "#000000"

posToPosPx :: Pos -> PosPx
posToPosPx (Tuple x y) = Tuple (x * cellWidthPx) (y * cellWidthPx)

at :: PosPx -> Graphics Unit -> Graphics Unit
at (Tuple x y) gfx = do
  save
  translate x y
  gfx
  restore

cell :: Number -> Graphics Unit
cell size = do
  beginPath
  setFillStyle foregroundColourHex
  rect { x: 0, y: 0, w: size, h: size }
  fill

clearCanvas :: Graphics Unit
clearCanvas = do
  setFillStyle backgroundColourHex
  rect { x: 0, y: 0, w: gridWidthPx, h: gridWidthPx }
  fill

seqn :: [Graphics Unit] -> Graphics Unit
seqn [] = return unit
seqn (a : as) = do a
                   seqn as

drawCalls :: Board -> [Graphics Unit]
drawCalls board = do
  p <- map posToPosPx board
  let gfx = at p $ cell cellWidthPx
  return gfx

drawScene :: forall eff. Board -> Graphics.Canvas.Context2D -> Eff (canvas :: Graphics.Canvas.Canvas |eff) Unit
drawScene board context = do
  runGraphics context $ do
    clearCanvas
    seqn $ drawCalls board

tick :: forall eff. Board -> Graphics.Canvas.Context2D -> Eff (raf :: RAF , canvas :: Graphics.Canvas.Canvas, trace :: Trace |eff) Unit
tick board context = do
  drawScene board context
  let board' = nextgen board
  requestAnimationFrame (tick board' context)

-- Start of computation
-----------------------
main = do
  canvas <- getCanvasElementById "canvas"
  context <- getContext2D canvas

  tick glider context

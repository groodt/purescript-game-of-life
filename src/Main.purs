module Main where

import Life

import Debug.Trace

import Data.Tuple
import Data.Array
import Data.Foldable

import Control.MonadPlus
import Control.Monad.Eff
import Control.RAF

import Graphics.Canvas (getCanvasElementById, getContext2D)
import Graphics.Canvas.Free

import Data.Date

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

tick :: forall eff. Board -> Graphics.Canvas.Context2D -> Number -> Eff (raf :: RAF , canvas :: Graphics.Canvas.Canvas, trace :: Trace , now :: Now |eff) Unit
tick board context t = do
  drawScene board context

  currentTime <- liftM1 toEpochMilliseconds now
  let elapsed = currentTime - t
  let board' = if elapsed > tickMs then (nextgen board) else board
  let t' = if elapsed > tickMs then currentTime else t

  requestAnimationFrame (tick board' context t')

-- Start of computation
-----------------------
main = do
  canvas <- getCanvasElementById "canvas"
  context <- getContext2D canvas

  tick glider context 0

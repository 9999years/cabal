module Distribution.VerboseException
  ( VerboseException (..)
  , withTimestamp
  , exceptionWithMetadata
  , exceptionWithCallStackPrefix
  ) where

import Distribution.Compat.Prelude ()

import GHC.Stack
  ( CallStack
  , withFrozenCallStack
  , prettyCallStack
  )
import Control.Exception (Exception(displayException))
import Data.Typeable (Typeable)
import Numeric (showFFloat)

import Distribution.Compat.Stack (parentSrcLocPrefix)
import Distribution.Verbosity
  ( Verbosity
  , isVerboseCallSite
  , isVerboseMarkOutput
  , verbose
  , isVerboseTimestamp
  )
import Distribution.SomeCabalException (SomeCabalException(getErrorCode))
import Distribution.OutputMarker (withOutputMarker, clearMarkers, withTrailingNewline)
import Distribution.Pretty (prettyShow)

import Data.Time.Clock.POSIX (POSIXTime)

-- Type which will be a wrapper for cabal -exceptions and cabal-install exceptions
data VerboseException a = VerboseException CallStack POSIXTime Verbosity a
  deriving (Show, Typeable)

instance SomeCabalException e => Exception (VerboseException e) where
  displayException (VerboseException stack timestamp verb inner) =
    withOutputMarker
      verb
      ( concat
          [ "Error: [Cabal-"
          , show (getErrorCode inner)
          , "]\n"
          ]
      )
      -- TODO: `exceptionWithMetadata` should operate on `Doc`.
      ++ exceptionWithMetadata stack timestamp verb (prettyShow inner)

-- | Add all necessary metadata to a logging message
--
-- TODO: This should operate on `Text.PrettyPrint.Doc`s instead of `String`s.
exceptionWithMetadata :: CallStack -> POSIXTime -> Verbosity -> String -> String
exceptionWithMetadata stack ts verbosity x =
  withTrailingNewline
    . exceptionWithCallStackPrefix stack verbosity
    . withOutputMarker verbosity
    . clearMarkers
    . withTimestamp verbosity ts
    $ x

-- | Append a call-site and/or call-stack based on Verbosity
exceptionWithCallStackPrefix :: CallStack -> Verbosity -> String -> String
exceptionWithCallStackPrefix stack verbosity s =
  s
    ++ withFrozenCallStack
      ( ( if isVerboseCallSite verbosity
            then
              parentSrcLocPrefix
                ++
                -- Hack: need a newline before starting output marker :(
                if isVerboseMarkOutput verbosity
                  then "\n"
                  else ""
            else ""
        )
          ++ ( if verbosity >= verbose
                then prettyCallStack stack ++ "\n"
                else ""
             )
      )

-- | Prepends a timestamp if @+timestamp@ verbosity flag is set
--
-- This is used by 'withMetadata'
withTimestamp :: Verbosity -> POSIXTime -> String -> String
withTimestamp v ts msg
  | isVerboseTimestamp v = msg'
  | otherwise = msg -- no-op
  where
    msg' = case lines msg of
      [] -> tsstr "\n"
      l1 : rest -> unlines (tsstr (' ' : l1) : map (contpfx ++) rest)

    -- format timestamp to be prepended to first line with msec precision
    tsstr = showFFloat (Just 3) (realToFrac ts :: Double)

    -- continuation prefix for subsequent lines of msg
    contpfx = replicate (length (tsstr " ")) ' '

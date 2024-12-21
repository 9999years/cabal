module Distribution.OutputMarker
  ( withOutputMarker
  , clearMarkers
  , withTrailingNewline
  ) where

import Distribution.Verbosity
  ( Verbosity
  , isVerboseMarkOutput
  )

-- | Wrap output with a marker if @+markoutput@ verbosity flag is set.
--
-- NB: Why is markoutput done with start/end markers, and not prefixes?
-- Markers are more convenient to add (if we want to add prefixes,
-- we have to 'lines' and then 'map'; here's it's just some
-- concatenates).  Note that even in the prefix case, we can't
-- guarantee that the markers are unambiguous, because some of
-- Cabal's output comes straight from external programs, where
-- we don't have the ability to interpose on the output.
--
-- This is used by 'withMetadata'
withOutputMarker :: Verbosity -> String -> String
withOutputMarker v xs | not (isVerboseMarkOutput v) = xs
withOutputMarker _ "" = "" -- Minor optimization, don't mark uselessly
withOutputMarker _ xs =
  "-----BEGIN CABAL OUTPUT-----\n"
    ++ withTrailingNewline xs
    ++ "-----END CABAL OUTPUT-----\n"

clearMarkers :: String -> String
clearMarkers s = unlines . filter isMarker $ lines s
  where
    isMarker "-----BEGIN CABAL OUTPUT-----" = False
    isMarker "-----END CABAL OUTPUT-----" = False
    isMarker _ = True

-- | Append a trailing newline to a string if it does not
-- already have a trailing newline.
withTrailingNewline :: String -> String
withTrailingNewline "" = ""
withTrailingNewline (x : xs) = x : go x xs
  where
    go _ (c : cs) = c : go c cs
    go '\n' "" = ""
    go _ "" = "\n"

{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}

module Distribution.IntoCabalException
  ( IntoCabalException (..)
  ) where

import Distribution.SomeCabalException (SomeCabalException)

-- | An `Exception` that can be converted into a `SomeCabalException`.
--
-- Exceptions thrown with `Distribution.Simple.Utils.dieWithException` must
-- implement `IntoCabalException` and will have error codes, stack traces,
-- output markers, etc.
--
-- This helps bridge the niceties of types like
-- `Distribution.Simple.Errors.CabalException` with richly typed and structured
-- exceptions that can be caught or otherwise introspected.
--
-- Generally, types like `Distribution.Simple.Errors.CabalException` cannot
-- contain structured data because they're included in almost every module, so
-- adding typed data causes import cycles.
--
-- Therefore, using `IntoCabalException` gives us the best of all worlds:
-- - We can throw structured exceptions from functions like
--   `Distribution.Simple.Utils.dieWithException`, letting us 
class SomeCabalException (TheCabalException e) =>
      IntoCabalException e where
  -- | The Cabal `Exception` type that this exception will be converted into.
  --
  -- This is typically either `Distribution.Simple.Errors.CabalException` (for
  -- errors from Cabal-the-library) or
  -- `Distribution.Client.Errors.CabalInstallException` (for errors from
  -- @cabal-install@ the program).
  type TheCabalException e
  intoCabalException :: e -> TheCabalException e

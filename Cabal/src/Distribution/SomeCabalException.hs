module Distribution.SomeCabalException
  ( SomeCabalException (..)
  ) where

import Data.Typeable (Typeable)
import Distribution.Pretty (Pretty)

-- | A Cabal `Exception` type.
--
-- Cabal errors have a few properties:
--
-- - Errors can be `Show`n and are `Typeable`. These are inherited from the
--   `Exception` class.
--
-- - Errors can be `Pretty`-printed. This is generally nicer and more composable
--   than `String`-based formatting.
--
--   In the future, we hope to add ANSI terminal colors to error messages (and
--   Cabal output in general).
--
-- - Errors have a unique error code accessed with `getErrorCode`.
--
-- The two main Cabal exception types are
-- `Distribution.Simple.Errors.CabalException` (for errors from
-- Cabal-the-library) or `Distribution.Client.Errors.CabalInstallException`
-- (for errors from @cabal-install@ the program).
--
-- Exceptions can be converted into a Cabal exception via the
-- `Distribution.IntoCabalException.IntoCabalException` class.
--
-- Errors implementing `SomeCabalException` are nicely formatted via
-- `Distribution.VerboseException.VerboseException`.
class
  ( Show e
  , Typeable e
  , Pretty e 
  ) => SomeCabalException e where
  -- | Get this error's unique error code.
  getErrorCode :: e -> Int

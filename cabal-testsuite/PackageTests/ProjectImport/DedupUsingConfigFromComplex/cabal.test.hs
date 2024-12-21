import Test.Cabal.Prelude

main = cabalTest $ do
  _ <- fails $ cabal' "v2-build" [ "--project-file=no-pkgs.project" ]
  pure ()

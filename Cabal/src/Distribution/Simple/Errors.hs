{-# LANGUAGE TypeFamilies #-}

-----------------------------------------------------------------------------

-- Module      :  Distribution.Simple.Errors
-- Copyright   :  Suganya Arun
-- License     :  BSD3
-- Maintainer  :  cabal-devel@haskell.org
-- Portability :  portable
--
-- A collection of Exception Types in the Cabal library package

module Distribution.Simple.Errors
  ( CabalException (..)
  , FailedDependency (..)
  ) where

import Distribution.Compat.Prelude
import Distribution.Compiler
import Distribution.InstalledPackageInfo
import Distribution.IntoCabalException (IntoCabalException (..))
import Distribution.ModuleName
import Distribution.Package
import Distribution.PackageDescription
import Distribution.Pretty
  ( Pretty (pretty)
  , prettyShow
  )
import Distribution.Simple.InstallDirs
import Distribution.Simple.PreProcess.Types (Suffix)
import Distribution.Simple.SetupHooks.Errors
import Distribution.SomeCabalException (SomeCabalException (..))
import Distribution.System (OS)
import Distribution.Types.MissingDependency (MissingDependency)
import Distribution.Types.VersionRange.Internal ()
import Distribution.Version

import Text.PrettyPrint

data FailedDependency
  = DependencyNotExists PackageName
  | DependencyMissingInternal PackageName LibraryName
  | DependencyNoVersion Dependency
  deriving (Show)

instance IntoCabalException CabalException where
  type TheCabalException CabalException = CabalException
  intoCabalException = id

-- Types representing exceptions thrown by functions in all the modules of Cabal Package
data CabalException
  = NoBenchMarkProgram FilePath
  | EnableBenchMark
  | BenchMarkNameDisabled String
  | NoBenchMark String
  | -- | @NoLibraryFound@ has been downgraded to a warning, and is therefore no longer emitted.
    NoLibraryFound
  | CompilerNotInstalled CompilerFlavor
  | CantFindIncludeFile String
  | UnsupportedTestSuite String
  | UnsupportedBenchMark String
  | NoIncludeFileFound String
  | NoModuleFound ModuleName [Suffix]
  | RegMultipleInstancePkg
  | SuppressingChecksOnFile
  | NoSupportDirStylePackageDb
  | OnlySupportSpecificPackageDb
  | FailedToParseOutputDescribe String PackageId
  | DumpFailed String String
  | FailedToParseOutputDump String
  | ListFailed String
  | FailedToParseOutputList String
  | ProgramNotFound String
  | NoSupportForHoogle
  | NoSupportForQuickJumpFlag
  | NoGHCVersionFromHaddock
  | NoGHCVersionFromCompiler
  | HaddockAndGHCVersionDoesntMatch Version Version
  | MustHaveSharedLibraries
  | HaddockPackageFlags [(InstalledPackageInfo, [UnitId])]
  | UnknownCompilerFlavor CompilerFlavor
  | FailedToDetermineTarget
  | NoMultipleTargets
  | REPLNotSupported
  | NoSupportBuildingTestSuite TestType
  | NoSupportBuildingBenchMark BenchmarkType
  | BuildingNotSupportedWithCompiler
  | ProvideHaskellSuiteTool String
  | CannotDetermineCompilerVersion
  | PkgDumpFailed
  | FailedToParseOutput
  | CantFindSourceModule ModuleName
  | VersionMismatchJS FilePath Version FilePath Version
  | VersionMismatchGHCJS FilePath Version FilePath Version
  | GlobalPackageDBLimitation
  | GlobalPackageDBSpecifiedFirst
  | MatchDirFileGlob String
  | MatchDirFileGlobErrors [String]
  | ErrorParsingFileDoesntExist FilePath
  | FailedParsing String
  | NotFoundMsg
  | UnrecognisedBuildTarget [String]
  | ReportBuildTargetProblems [(String, [String], String)]
  | UnknownBuildTarget [(String, [(String, String)])]
  | AmbiguousBuildTarget [(String, [(String, String)])]
  | CheckBuildTargets String
  | VersionMismatchGHC FilePath Version FilePath Version
  | CheckPackageDbStackPost76
  | CheckPackageDbStackPre76
  | GlobalPackageDbSpecifiedFirst
  | CantInstallForeignLib
  | NoSupportForPreProcessingTest TestType
  | NoSupportForPreProcessingBenchmark BenchmarkType
  | CantFindSourceForPreProcessFile String
  | NoSupportPreProcessingTestExtras TestType
  | NoSupportPreProcessingBenchmarkExtras BenchmarkType
  | UnlitException String
  | RunProgramInvocationException FilePath String
  | GetProgramInvocationException FilePath String
  | GetProgramInvocationLBSException FilePath String
  | CheckSemaphoreSupport
  | NoLibraryForPackage
  | SanityCheckHookedBuildInfo UnqualComponentName
  | ConfigureScriptNotFound FilePath
  | NoValidComponent
  | ConfigureEitherSingleOrAll
  | ConfigCIDValidForPreComponent
  | SanityCheckForEnableComponents
  | SanityCheckForDynamicStaticLinking
  | UnsupportedLanguages PackageIdentifier CompilerId [String]
  | UnsupportedLanguageExtension PackageIdentifier CompilerId [String]
  | CantFindForeignLibraries [String]
  | ExpectedAbsoluteDirectory FilePath
  | FlagsNotSpecified [FlagName]
  | EncounteredMissingDependency [MissingDependency]
  | CompilerDoesn'tSupportThinning
  | CompilerDoesn'tSupportReexports
  | CompilerDoesn'tSupportBackpack
  | LibraryWithinSamePackage [PackageId]
  | ReportFailedDependencies [FailedDependency] String
  | NoPackageDatabaseSpecified
  | HowToFindInstalledPackages CompilerFlavor
  | PkgConfigNotFound String String
  | BadVersion String String PkgconfigVersion
  | UnknownCompilerException
  | NoWorkingGcc
  | NoOSSupport OS String
  | NoCompilerSupport String
  | InstallDirsNotPrefixRelative (InstallDirs FilePath)
  | ExplainErrors (Maybe (Either [Char] [Char])) [String]
  | CheckPackageProblems [String]
  | LibDirDepsPrefixNotRelative FilePath FilePath
  | CombinedConstraints Doc
  | CantParseGHCOutput
  | IncompatibleWithCabal String String
  | Couldn'tFindTestProgram FilePath
  | TestCoverageSupport
  | Couldn'tFindTestProgLibV09 FilePath
  | TestCoverageSupportLibV09
  | RawSystemStdout String
  | FindFile FilePath
  | FindModuleFileEx ModuleName [Suffix] [FilePath]
  | MultipleFilesWithExtension String
  | NoDesc
  | MultiDesc [String]
  | RelocRegistrationInfo
  | CreatePackageDB
  | WithHcPkg String
  | RegisMultiplePkgNotSupported
  | RegisteringNotImplemented
  | NoTestSuitesEnabled
  | TestNameDisabled String
  | NoSuchTest String
  | ConfigureProgram String FilePath
  | RequireProgram String
  | NoProgramFound String VersionRange
  | BadVersionDb String Version VersionRange FilePath
  | UnknownVersionDb String VersionRange FilePath
  | MissingCoveredInstalledLibrary UnitId
  | SetupHooksException SetupHooksException
  deriving (Show, Typeable)

instance SomeCabalException CabalException where
  getErrorCode e = case e of
    NoBenchMarkProgram{} -> 1678
    EnableBenchMark{} -> 1453
    BenchMarkNameDisabled{} -> 2781
    NoBenchMark{} -> 1654
    NoLibraryFound -> 2546
    CompilerNotInstalled{} -> 7465
    CantFindIncludeFile{} -> 3876
    UnsupportedTestSuite{} -> 3245
    UnsupportedBenchMark{} -> 9123
    NoIncludeFileFound{} -> 2987
    NoModuleFound{} -> 6421
    RegMultipleInstancePkg{} -> 3421
    SuppressingChecksOnFile{} -> 5436
    NoSupportDirStylePackageDb -> 2980
    OnlySupportSpecificPackageDb -> 6547
    FailedToParseOutputDescribe{} -> 7218
    DumpFailed{} -> 6736
    FailedToParseOutputDump{} -> 9076
    ListFailed{} -> 5109
    FailedToParseOutputList{} -> 7650
    ProgramNotFound{} -> 4123
    NoSupportForHoogle{} -> 8706
    NoSupportForQuickJumpFlag{} -> 7086
    NoGHCVersionFromHaddock -> 5045
    NoGHCVersionFromCompiler -> 4098
    HaddockAndGHCVersionDoesntMatch{} -> 1998
    MustHaveSharedLibraries{} -> 6032
    HaddockPackageFlags{} -> 4569
    UnknownCompilerFlavor{} -> 3102
    FailedToDetermineTarget{} -> 5049
    NoMultipleTargets{} -> 6091
    REPLNotSupported{} -> 1098
    NoSupportBuildingTestSuite{} -> 4106
    NoSupportBuildingBenchMark{} -> 5320
    BuildingNotSupportedWithCompiler{} -> 7077
    ProvideHaskellSuiteTool{} -> 7509
    CannotDetermineCompilerVersion{} -> 4519
    PkgDumpFailed{} -> 2291
    FailedToParseOutput{} -> 5500
    CantFindSourceModule{} -> 8870
    VersionMismatchJS{} -> 9001
    VersionMismatchGHCJS{} -> 4001
    GlobalPackageDBLimitation{} -> 5002
    GlobalPackageDBSpecifiedFirst{} -> 3901
    MatchDirFileGlob{} -> 9760
    MatchDirFileGlobErrors{} -> 6661
    ErrorParsingFileDoesntExist{} -> 1234
    FailedParsing{} -> 6565
    NotFoundMsg{} -> 8011
    UnrecognisedBuildTarget{} -> 3410
    ReportBuildTargetProblems{} -> 5504
    UnknownBuildTarget{} -> 4444
    AmbiguousBuildTarget{} -> 7865
    CheckBuildTargets{} -> 4733
    VersionMismatchGHC{} -> 4000
    CheckPackageDbStackPost76{} -> 3000
    CheckPackageDbStackPre76{} -> 5640
    GlobalPackageDbSpecifiedFirst{} -> 2345
    CantInstallForeignLib{} -> 8221
    NoSupportForPreProcessingTest{} -> 3008
    NoSupportForPreProcessingBenchmark{} -> 6990
    CantFindSourceForPreProcessFile{} -> 7554
    NoSupportPreProcessingTestExtras{} -> 7886
    NoSupportPreProcessingBenchmarkExtras{} -> 9999
    UnlitException{} -> 5454
    RunProgramInvocationException{} -> 8012
    GetProgramInvocationException{} -> 7300
    GetProgramInvocationLBSException{} -> 6578
    CheckSemaphoreSupport{} -> 2002
    NoLibraryForPackage{} -> 8004
    SanityCheckHookedBuildInfo{} -> 6007
    ConfigureScriptNotFound{} -> 4567
    NoValidComponent{} -> 5680
    ConfigureEitherSingleOrAll{} -> 2001
    ConfigCIDValidForPreComponent{} -> 7006
    SanityCheckForEnableComponents{} -> 5004
    SanityCheckForDynamicStaticLinking{} -> 4007
    UnsupportedLanguages{} -> 8074
    UnsupportedLanguageExtension{} -> 5656
    CantFindForeignLibraries{} -> 4574
    ExpectedAbsoluteDirectory{} -> 6662
    FlagsNotSpecified{} -> 9080
    EncounteredMissingDependency{} -> 8010
    CompilerDoesn'tSupportThinning{} -> 4003
    CompilerDoesn'tSupportReexports{} -> 3456
    CompilerDoesn'tSupportBackpack{} -> 5446
    LibraryWithinSamePackage{} -> 7007
    ReportFailedDependencies{} -> 4321
    NoPackageDatabaseSpecified{} -> 2300
    HowToFindInstalledPackages{} -> 3003
    PkgConfigNotFound{} -> 7123
    BadVersion{} -> 7600
    UnknownCompilerException{} -> 3022
    NoWorkingGcc{} -> 1088
    NoOSSupport{} -> 3339
    NoCompilerSupport{} -> 2290
    InstallDirsNotPrefixRelative{} -> 6000
    ExplainErrors{} -> 4345
    CheckPackageProblems{} -> 5559
    LibDirDepsPrefixNotRelative{} -> 6667
    CombinedConstraints{} -> 5000
    CantParseGHCOutput{} -> 1980
    IncompatibleWithCabal{} -> 8123
    Couldn'tFindTestProgram{} -> 5678
    TestCoverageSupport{} -> 7890
    Couldn'tFindTestProgLibV09{} -> 9012
    TestCoverageSupportLibV09{} -> 1076
    RawSystemStdout{} -> 3098
    FindFile{} -> 2115
    FindModuleFileEx{} -> 6663
    MultipleFilesWithExtension{} -> 3333
    NoDesc{} -> 7654
    MultiDesc{} -> 5554
    RelocRegistrationInfo{} -> 4343
    CreatePackageDB{} -> 6787
    WithHcPkg{} -> 9876
    RegisMultiplePkgNotSupported{} -> 7632
    RegisteringNotImplemented{} -> 5411
    NoTestSuitesEnabled{} -> 9061
    TestNameDisabled{} -> 8210
    NoSuchTest{} -> 8000
    ConfigureProgram{} -> 5490
    RequireProgram{} -> 6666
    NoProgramFound{} -> 7620
    BadVersionDb{} -> 8038
    UnknownVersionDb{} -> 1008
    MissingCoveredInstalledLibrary{} -> 9341
    SetupHooksException err ->
      setupHooksExceptionCode err

instance Pretty CabalException where
  pretty e = case e of
    NoBenchMarkProgram cmd -> text $ "Could not find benchmark program \"" ++ cmd ++ "\". Did you build the package first?"
    EnableBenchMark -> text $ "No benchmarks enabled. Did you remember to \'Setup configure\' with " ++ "\'--enable-benchmarks\'?"
    BenchMarkNameDisabled bmName -> text $ "Package configured with benchmark " ++ bmName ++ " disabled."
    NoBenchMark bmName -> text $ "no such benchmark: " ++ bmName
    NoLibraryFound -> text $ "No executables and no library found. Nothing to do."
    CompilerNotInstalled compilerFlavor -> text $ "installing with " ++ prettyShow compilerFlavor ++ "is not implemented"
    CantFindIncludeFile file -> text $ "can't find include file " ++ file
    UnsupportedTestSuite test_type -> text $ "Unsupported test suite type: " ++ test_type
    UnsupportedBenchMark benchMarkType -> text $ "Unsupported benchmark type: " ++ benchMarkType
    NoIncludeFileFound f -> text $ "can't find include file " ++ f
    NoModuleFound m suffixes ->
      text $
        "Could not find module: "
          ++ prettyShow m
          ++ " with any suffix: "
          ++ show (map prettyShow suffixes)
          ++ ".\n"
          ++ "If the module "
          ++ "is autogenerated it should be added to 'autogen-modules'."
    RegMultipleInstancePkg -> text $ "HcPkg.register: the compiler does not support registering multiple instances of packages."
    SuppressingChecksOnFile -> text $ "HcPkg.register: the compiler does not support suppressing checks on files."
    NoSupportDirStylePackageDb -> text $ "HcPkg.writeRegistrationFileDirectly: compiler does not support dir style package dbs"
    OnlySupportSpecificPackageDb -> text $ "HcPkg.writeRegistrationFileDirectly: only supports SpecificPackageDB for now"
    FailedToParseOutputDescribe programId pkgId -> text $ "failed to parse output of '" ++ programId ++ " describe " ++ prettyShow pkgId ++ "'"
    DumpFailed programId exception -> text $ programId ++ " dump failed: " ++ exception
    FailedToParseOutputDump programId -> text $ "failed to parse output of '" ++ programId ++ " dump'"
    ListFailed programId -> text $ programId ++ " list failed"
    FailedToParseOutputList programId -> text $ "failed to parse output of '" ++ programId ++ " list'"
    ProgramNotFound progName -> text $ "The program '" ++ progName ++ "' is required but it could not be found"
    NoSupportForHoogle -> text $ "Haddock 2.0 and 2.1 do not support the --hoogle flag."
    NoSupportForQuickJumpFlag -> text $ "Haddock prior to 2.19 does not support the --quickjump flag."
    NoGHCVersionFromHaddock -> text $ "Could not get GHC version from Haddock"
    NoGHCVersionFromCompiler -> text $ "Could not get GHC version from compiler"
    HaddockAndGHCVersionDoesntMatch ghcVersion haddockGhcVersion ->
      text $
        "Haddock's internal GHC version must match the configured "
          ++ "GHC version.\n"
          ++ "The GHC version is "
          ++ prettyShow ghcVersion
          ++ " but "
          ++ "haddock is using GHC version "
          ++ prettyShow haddockGhcVersion
    MustHaveSharedLibraries -> text $ "Must have vanilla or shared libraries enabled in order to run haddock"
    HaddockPackageFlags inf ->
      text $
        "internal error when calculating transitive "
          ++ "package dependencies.\nDebug info: "
          ++ show inf
    UnknownCompilerFlavor compilerFlavor -> text $ "dumpBuildInfo: Unknown compiler flavor: " ++ show compilerFlavor
    FailedToDetermineTarget -> text $ "Failed to determine target."
    NoMultipleTargets -> text $ "The 'repl' command does not support multiple targets at once."
    REPLNotSupported -> text $ "A REPL is not supported with this compiler."
    NoSupportBuildingTestSuite test_type -> text $ "No support for building test suite type " ++ show test_type
    NoSupportBuildingBenchMark benchMarkType -> text $ "No support for building benchmark type " ++ show benchMarkType
    BuildingNotSupportedWithCompiler -> text $ "Building is not supported with this compiler."
    ProvideHaskellSuiteTool msg -> text $ show msg
    CannotDetermineCompilerVersion -> text $ "haskell-suite: couldn't determine compiler version"
    PkgDumpFailed -> text $ "pkg dump failed"
    FailedToParseOutput -> text $ "failed to parse output of 'pkg dump'"
    CantFindSourceModule moduleName -> text $ "can't find source for module " ++ prettyShow moduleName
    VersionMismatchJS ghcjsProgPath ghcjsVersion ghcjsPkgProgPath ghcjsPkgGhcjsVersion ->
      text $
        "Version mismatch between ghcjs and ghcjs-pkg: "
          ++ show ghcjsProgPath
          ++ " is version "
          ++ prettyShow ghcjsVersion
          ++ " "
          ++ show ghcjsPkgProgPath
          ++ " is version "
          ++ prettyShow ghcjsPkgGhcjsVersion
    VersionMismatchGHCJS ghcjsProgPath ghcjsGhcVersion ghcjsPkgProgPath ghcjsPkgVersion ->
      text $
        "Version mismatch between ghcjs and ghcjs-pkg: "
          ++ show ghcjsProgPath
          ++ " was built with GHC version "
          ++ prettyShow ghcjsGhcVersion
          ++ " "
          ++ show ghcjsPkgProgPath
          ++ " was built with GHC version "
          ++ prettyShow ghcjsPkgVersion
    GlobalPackageDBLimitation ->
      text $
        "With current ghc versions the global package db is always used "
          ++ "and must be listed first. This ghc limitation may be lifted in "
          ++ "the future, see https://gitlab.haskell.org/ghc/ghc/-/issues/5977"
    GlobalPackageDBSpecifiedFirst ->
      text $
        "If the global package db is specified, it must be "
          ++ "specified first and cannot be specified multiple times"
    MatchDirFileGlob pathError -> text $ pathError
    MatchDirFileGlobErrors errors -> text $ unlines errors
    ErrorParsingFileDoesntExist filePath -> text $ "Error Parsing: file \"" ++ filePath ++ "\" doesn't exist. Cannot continue."
    FailedParsing name -> text $ "Failed parsing \"" ++ name ++ "\"."
    NotFoundMsg ->
      text $
        "The package has a './configure' script. "
          ++ "If you are on Windows, This requires a "
          ++ "Unix compatibility toolchain such as MinGW+MSYS or Cygwin. "
          ++ "If you are not on Windows, ensure that an 'sh' command "
          ++ "is discoverable in your path."
    UnrecognisedBuildTarget target ->
      text $
        unlines
          [ "Unrecognised build target '" ++ name ++ "'."
          | name <- target
          ]
          ++ "Examples:\n"
          ++ " - build foo          -- component name "
          ++ "(library, executable, test-suite or benchmark)\n"
          ++ " - build Data.Foo     -- module name\n"
          ++ " - build Data/Foo.hsc -- file name\n"
          ++ " - build lib:foo exe:foo   -- component qualified by kind\n"
          ++ " - build foo:Data.Foo      -- module qualified by component\n"
          ++ " - build foo:Data/Foo.hsc  -- file qualified by component"
    ReportBuildTargetProblems targets ->
      text $
        unlines
          [ "Unrecognised build target '"
            ++ target
            ++ "'.\n"
            ++ "Expected a "
            ++ intercalate " or " expected
            ++ ", rather than '"
            ++ got
            ++ "'."
          | (target, expected, got) <- targets
          ]
    UnknownBuildTarget targets ->
      text $
        unlines
          [ "Unknown build target '"
            ++ target
            ++ "'.\nThere is no "
            ++ intercalate
              " or "
              [ mungeThing thing ++ " '" ++ got ++ "'"
              | (thing, got) <- nosuch
              ]
            ++ "."
          | (target, nosuch) <- targets
          ]
      where
        mungeThing "file" = "file target"
        mungeThing thing = thing
    AmbiguousBuildTarget targets ->
      text $
        unlines
          [ "Ambiguous build target '"
            ++ target
            ++ "'. It could be:\n "
            ++ unlines
              [ "   "
                ++ ut
                ++ " ("
                ++ bt
                ++ ")"
              | (ut, bt) <- amb
              ]
          | (target, amb) <- targets
          ]
    CheckBuildTargets errorStr -> text $ errorStr
    VersionMismatchGHC ghcProgPath ghcVersion ghcPkgProgPath ghcPkgVersion ->
      text $
        "Version mismatch between ghc and ghc-pkg: "
          ++ ghcProgPath
          ++ " is version "
          ++ prettyShow ghcVersion
          ++ " "
          ++ ghcPkgProgPath
          ++ " is version "
          ++ prettyShow ghcPkgVersion
    CheckPackageDbStackPost76 ->
      text $
        "If the global package db is specified, it must be "
          ++ "specified first and cannot be specified multiple times"
    CheckPackageDbStackPre76 ->
      text $
        "With current ghc versions the global package db is always used "
          ++ "and must be listed first. This ghc limitation is lifted in GHC 7.6,"
          ++ "see https://gitlab.haskell.org/ghc/ghc/-/issues/5977"
    GlobalPackageDbSpecifiedFirst ->
      text $
        "If the global package db is specified, it must be "
          ++ "specified first and cannot be specified multiple times"
    CantInstallForeignLib -> text $ "Can't install foreign-library symlink on non-Linux OS"
    NoSupportForPreProcessingTest tt ->
      text $
        "No support for preprocessing test "
          ++ "suite type "
          ++ prettyShow tt
    NoSupportForPreProcessingBenchmark tt ->
      text $
        "No support for preprocessing benchmark type "
          ++ prettyShow tt
    CantFindSourceForPreProcessFile errorStr -> text $ errorStr
    NoSupportPreProcessingTestExtras tt ->
      text $
        "No support for preprocessing test suite type "
          ++ prettyShow tt
    NoSupportPreProcessingBenchmarkExtras tt ->
      text $
        "No support for preprocessing benchmark "
          ++ "type "
          ++ prettyShow tt
    UnlitException str -> text $ str
    RunProgramInvocationException path errors -> text $ "'" ++ path ++ "' exited with an error:\n" ++ errors
    GetProgramInvocationException path errors -> text $ "'" ++ path ++ "' exited with an error:\n" ++ errors
    GetProgramInvocationLBSException path errors -> text $ "'" ++ path ++ "' exited with an error:\n" ++ errors
    CheckSemaphoreSupport ->
      text $
        "Your compiler does not support the -jsem flag. "
          ++ "To use this feature you must use GHC 9.8 or later."
    NoLibraryForPackage ->
      text $
        "The buildinfo contains info for a library, "
          ++ "but the package does not have a library."
    SanityCheckHookedBuildInfo exe1 ->
      text $
        "The buildinfo contains info for an executable called '"
          ++ prettyShow exe1
          ++ "' but the package does not have an "
          ++ "executable with that name."
    ConfigureScriptNotFound fp -> text $ "configure script not found at " ++ fp ++ "."
    NoValidComponent -> text $ "No valid component targets found"
    ConfigureEitherSingleOrAll -> text $ "Can only configure either a single component or all of them"
    ConfigCIDValidForPreComponent -> text $ "--cid is only supported for per-component configure"
    SanityCheckForEnableComponents ->
      text $
        "--enable-tests/--enable-benchmarks are incompatible with"
          ++ " explicitly specifying a component to configure."
    SanityCheckForDynamicStaticLinking ->
      text $
        "--enable-executable-dynamic and --enable-executable-static"
          ++ " are incompatible with each other."
    UnsupportedLanguages pkgId compilerId langs ->
      text $
        "The package "
          ++ prettyShow pkgId
          ++ " requires the following languages which are not "
          ++ "supported by "
          ++ prettyShow compilerId
          ++ ": "
          ++ intercalate ", " langs
    UnsupportedLanguageExtension pkgId compilerId exts ->
      text $
        "The package "
          ++ prettyShow pkgId
          ++ " requires the following language extensions which are not "
          ++ "supported by "
          ++ prettyShow compilerId
          ++ ": "
          ++ intercalate ", " exts
    CantFindForeignLibraries unsupportedFLibs ->
      text $
        "Cannot build some foreign libraries: "
          ++ intercalate ", " unsupportedFLibs
    ExpectedAbsoluteDirectory fPath -> text $ "expected an absolute directory name for --prefix: " ++ fPath
    FlagsNotSpecified diffFlags ->
      text $
        "'--exact-configuration' was given, "
          ++ "but the following flags were not specified: "
          ++ intercalate ", " (map show diffFlags)
    EncounteredMissingDependency missing ->
      text $
        "Encountered missing or private dependencies:\n"
          ++ ( render
                . nest 4
                . sep
                . punctuate comma
                . map pretty
                $ missing
             )
    CompilerDoesn'tSupportThinning ->
      text $
        "Your compiler does not support thinning and renaming on "
          ++ "package flags.  To use this feature you must use "
          ++ "GHC 7.9 or later."
    CompilerDoesn'tSupportReexports ->
      text $
        "Your compiler does not support module re-exports. To use "
          ++ "this feature you must use GHC 7.9 or later."
    CompilerDoesn'tSupportBackpack ->
      text $
        "Your compiler does not support Backpack. To use "
          ++ "this feature you must use GHC 8.1 or later."
    LibraryWithinSamePackage internalPkgDeps ->
      text $
        "The field 'build-depends: "
          ++ intercalate ", " (map (prettyShow . packageName) internalPkgDeps)
          ++ "' refers to a library which is defined within the same "
          ++ "package. To use this feature the package must specify at "
          ++ "least 'cabal-version: >= 1.8'."
    ReportFailedDependencies failed hackageUrl -> text $ intercalate "\n\n" (map reportFailedDependency failed)
      where
        reportFailedDependency (DependencyNotExists pkgname) =
          "there is no version of "
            ++ prettyShow pkgname
            ++ " installed.\n"
            ++ "Perhaps you need to download and install it from\n"
            ++ hackageUrl
            ++ prettyShow pkgname
            ++ "?"
        reportFailedDependency (DependencyMissingInternal pkgname lib) =
          "internal dependency "
            ++ prettyShow (prettyLibraryNameComponent lib)
            ++ " not installed.\n"
            ++ "Perhaps you need to configure and install it first?\n"
            ++ "(This library was defined by "
            ++ prettyShow pkgname
            ++ ")"
        reportFailedDependency (DependencyNoVersion dep) =
          "cannot satisfy dependency " ++ prettyShow (simplifyDependency dep) ++ "\n"
    NoPackageDatabaseSpecified ->
      text $
        "No package databases have been specified. If you use "
          ++ "--package-db=clear, you must follow it with --package-db= "
          ++ "with 'global', 'user' or a specific file."
    HowToFindInstalledPackages flv ->
      text $
        "don't know how to find the installed packages for "
          ++ prettyShow flv
    PkgConfigNotFound pkg versionReq ->
      text $
        "The pkg-config package '"
          ++ pkg
          ++ "'"
          ++ versionReq
          ++ " is required but it could not be found."
    BadVersion pkg versionReq v ->
      text $
        "The pkg-config package '"
          ++ pkg
          ++ "'"
          ++ versionReq
          ++ " is required but the version installed on the"
          ++ " system is version "
          ++ prettyShow v
    UnknownCompilerException -> text $ "Unknown compiler"
    NoWorkingGcc ->
      text $
        unlines
          [ "No working gcc"
          , "This package depends on a foreign library but we cannot "
              ++ "find a working C compiler. If you have it in a "
              ++ "non-standard location you can use the --with-gcc "
              ++ "flag to specify it."
          ]
    NoOSSupport os what ->
      text $
        "Operating system: "
          ++ prettyShow os
          ++ ", does not support "
          ++ what
    NoCompilerSupport comp ->
      text $
        "Compiler: "
          ++ comp
          ++ ", does not support relocatable builds"
    InstallDirsNotPrefixRelative installDirs -> text $ "Installation directories are not prefix_relative:\n" ++ show installDirs
    ExplainErrors hdr libs ->
      text $
        unlines $
          [ if plural
            then "Missing dependencies on foreign libraries:"
            else "Missing dependency on a foreign library:"
          | missing
          ]
            ++ case hdr of
              Just (Left h) -> ["* Missing (or bad) header file: " ++ h]
              _ -> []
            ++ case libs of
              [] -> []
              [lib] -> ["* Missing (or bad) C library: " ++ lib]
              _ ->
                [ "* Missing (or bad) C libraries: "
                    ++ intercalate ", " libs
                ]
                  ++ [if plural then messagePlural else messageSingular | missing]
            ++ case hdr of
              Just (Left _) -> [headerCppMessage]
              Just (Right h) ->
                [ (if missing then "* " else "")
                    ++ "Bad header file: "
                    ++ h
                , headerCcMessage
                ]
              _ -> []
      where
        plural = length libs >= 2
        -- Is there something missing? (as opposed to broken)
        missing =
          not (null libs)
            || case hdr of Just (Left _) -> True; _ -> False
        messageSingular =
          "This problem can usually be solved by installing the system "
            ++ "package that provides this library (you may need the "
            ++ "\"-dev\" version). If the library is already installed "
            ++ "but in a non-standard location then you can use the flags "
            ++ "--extra-include-dirs= and --extra-lib-dirs= to specify "
            ++ "where it is."
            ++ "If the library file does exist, it may contain errors that "
            ++ "are caught by the C compiler at the preprocessing stage. "
            ++ "In this case you can re-run 'Setup configure' with the "
            ++ "verbosity flag -v3 to see the error messages."
        messagePlural =
          "This problem can usually be solved by installing the system "
            ++ "packages that provide these libraries (you may need the "
            ++ "\"-dev\" versions). If the libraries are already installed "
            ++ "but in a non-standard location then you can use the flags "
            ++ "--extra-include-dirs= and --extra-lib-dirs= to specify "
            ++ "where they are."
            ++ "If the library files do exist, it may contain errors that "
            ++ "are caught by the C compiler at the preprocessing stage. "
            ++ "In this case you can re-run 'Setup configure' with the "
            ++ "verbosity flag -v3 to see the error messages."
        headerCppMessage =
          "If the header file does exist, it may contain errors that "
            ++ "are caught by the C compiler at the preprocessing stage. "
            ++ "In this case you can re-run 'Setup configure' with the "
            ++ "verbosity flag -v3 to see the error messages."
        headerCcMessage =
          "The header file contains a compile error. "
            ++ "You can re-run 'Setup configure' with the verbosity flag "
            ++ "-v3 to see the error messages from the C compiler."
    CheckPackageProblems errors -> text $ intercalate "\n\n" errors
    LibDirDepsPrefixNotRelative l p ->
      text $
        "Library directory of a dependency: "
          ++ show l
          ++ "\nis not relative to the installation prefix:\n"
          ++ show p
    CombinedConstraints dispDepend ->
      text $
        render $
          text "The following package dependencies were requested"
            $+$ nest 4 dispDepend
            $+$ text "however the given installed package instance does not exist."
    CantParseGHCOutput -> text $ "Can't parse --info output of GHC"
    IncompatibleWithCabal compilerName packagePathEnvVar ->
      text $
        "Use of "
          ++ compilerName
          ++ "'s environment variable "
          ++ packagePathEnvVar
          ++ " is incompatible with Cabal. Use the "
          ++ "flag --package-db to specify a package database (it can be "
          ++ "used multiple times)."
    Couldn'tFindTestProgram cmd ->
      text $
        "Could not find test program \""
          ++ cmd
          ++ "\". Did you build the package first?"
    TestCoverageSupport -> text $ "Test coverage is only supported for packages with a library component."
    Couldn'tFindTestProgLibV09 cmd ->
      text $
        "Could not find test program \""
          ++ cmd
          ++ "\". Did you build the package first?"
    TestCoverageSupportLibV09 -> text $ "Test coverage is only supported for packages with a library component."
    RawSystemStdout errors -> text $ errors
    FindFile fileName -> text $ fileName ++ " doesn't exist"
    FindModuleFileEx mod_name extensions searchPath ->
      text $
        "Could not find module: "
          ++ prettyShow mod_name
          ++ " with any suffix: "
          ++ show (map prettyShow extensions)
          ++ " in the search path: "
          ++ show searchPath
    MultipleFilesWithExtension buildInfoExt -> text $ "Multiple files with extension " ++ buildInfoExt
    NoDesc ->
      text $
        "No cabal file found.\n"
          ++ "Please create a package description file <pkgname>.cabal"
    MultiDesc l ->
      text $
        "Multiple cabal files found.\n"
          ++ "Please use only one of: "
          ++ intercalate ", " l
    RelocRegistrationInfo ->
      text $
        "Distribution.Simple.Register.relocRegistrationInfo: \
        \not implemented for this compiler"
    CreatePackageDB ->
      text $
        "Distribution.Simple.Register.createPackageDB: "
          ++ "not implemented for this compiler"
    WithHcPkg name ->
      text $
        "Distribution.Simple.Register."
          ++ name
          ++ ":\
             \not implemented for this compiler"
    RegisMultiplePkgNotSupported -> text $ "Registering multiple package instances is not yet supported for this compiler"
    RegisteringNotImplemented -> text $ "Registering is not implemented for this compiler"
    NoTestSuitesEnabled ->
      text $
        "No test suites enabled. Did you remember to 'Setup configure' with "
          ++ "\'--enable-tests\'?"
    TestNameDisabled tName ->
      text $
        "Package configured with test suite "
          ++ tName
          ++ " disabled."
    NoSuchTest tName -> text $ "no such test: " ++ tName
    ConfigureProgram name path ->
      text $
        "Cannot find the program '"
          ++ name
          ++ "'. User-specified path '"
          ++ path
          ++ "' does not refer to an executable and "
          ++ "the program is not on the system path."
    RequireProgram progName -> text $ "The program '" ++ progName ++ "' is required but it could not be found."
    NoProgramFound progName versionRange ->
      text $
        "The program '"
          ++ progName
          ++ "'"
          ++ versionRequirement versionRange
          ++ " is required but it could not be found."
    BadVersionDb progName version range locationPath ->
      text $
        "The program '"
          ++ progName
          ++ "'"
          ++ versionRequirement range
          ++ " is required but the version found at "
          ++ locationPath
          ++ " is version "
          ++ prettyShow version
    UnknownVersionDb progName versionRange locationPath ->
      text $
        "The program '"
          ++ progName
          ++ "'"
          ++ versionRequirement versionRange
          ++ " is required but the version of "
          ++ locationPath
          ++ " could not be determined."
    MissingCoveredInstalledLibrary unitId ->
      text $
        "Failed to find the installed unit '"
          ++ prettyShow unitId
          ++ "' in package database stack."
    SetupHooksException err ->
      text $
        setupHooksExceptionMessage err

versionRequirement :: VersionRange -> String
versionRequirement range
  | isAnyVersion range = ""
  | otherwise = " version " ++ prettyShow range

{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fno-warn-incomplete-uni-patterns #-}

-----------------------------------------------------------------------------

-- Module      :  Distribution.Client.Errors
-- Copyright   :  Suganya Arun
-- License     :  BSD3
-- Maintainer  :  cabal-devel@haskell.org
-- Portability :  portable

-- A collection of Exception Types in the Cabal-Install library package

module Distribution.Client.Errors
  ( CabalInstallException (..)
  ) where

import Data.ByteString (ByteString)
import qualified Data.ByteString.Base16 as Base16
import qualified Data.ByteString.Char8 as BS8
import Data.List (groupBy)
import Distribution.Client.IndexUtils.Timestamp
import qualified Distribution.Client.Types.Repo as Repo
import qualified Distribution.Client.Types.RepoName as RepoName
import Distribution.Compat.Prelude
import Distribution.Deprecated.ParseUtils (PWarning, showPWarning)
import Distribution.IntoCabalException (IntoCabalException (..))
import Distribution.Package
import Distribution.Pretty
import Distribution.Simple (VersionRange)
import Distribution.SomeCabalException (SomeCabalException (..))

import Network.URI
import Text.PrettyPrint
import Text.Regex.Posix.ByteString (WrapError)

instance IntoCabalException CabalInstallException where
  type TheCabalException CabalInstallException = CabalInstallException
  intoCabalException = id

data CabalInstallException
  = UnpackGet
  | NotTarballDir FilePath
  | DirectoryAlreadyExists FilePath
  | FileExists FilePath
  | FileAlreadyExists FilePath
  | DirectoryExists FilePath
  | SplitRunArgs String
  | CouldNotFindExecutable
  | FoundMultipleMatchingExes
  | NoRemoteRepositories
  | NotATarDotGzFile FilePath
  | ExpectedMatchingFileName
  | NoTargetProvided
  | OneTargetRequired
  | ThisIsABug
  | NoOrMultipleTargetsGiven
  | NoTargetFound
  | MultipleTargetsFound
  | UnexpectedNamedPkgSpecifiers
  | UnexpectedSourcePkgSpecifiers
  | UnableToPerformInplaceUpdate
  | EmptyValuePagerEnvVariable
  | FileDoesntExist FilePath
  | ParseError
  | CabalFileNotFound FilePath
  | FindOpenProgramLocationErr String
  | PkgConfParseFailed String
  | ErrorPackingSdist String
  | SdistException PackageIdentifier
  | SpecifyAnExecutable
  | TestCommandDoesn'tSupport
  | ReportTargetProblems String
  | ListBinTargetException String
  | ResolveWithoutDependency String
  | CannotReadCabalFile FilePath
  | ErrorUpdatingIndex FilePath IOException
  | InternalError FilePath
  | ReadIndexCache FilePath
  | ConfigStateFileException String
  | UploadAction
  | UploadActionDocumentation
  | UploadActionOnlyArchives [FilePath]
  | FileNotFound FilePath
  | CheckAction [String]
  | ReportAction [String]
  | InitAction
  | UserConfigAction FilePath
  | SpecifySubcommand
  | UnknownUserConfigSubcommand [String]
  | ManpageAction [String]
  | UnrecognizedResponse
  | CheckTarget
  | FetchPackage
  | PlanPackages String
  | NoSupportForRunCommand
  | RunPhaseReached
  | UnknownExecutable String UnitId
  | MultipleMatchingExecutables String [String]
  | CmdRunReportTargetProblems String
  | CleanAction [String]
  | ReportCannotPruneDependencies String
  | ReplCommandDoesn'tSupport
  | ReplTakesNoArguments [String]
  | ReplTakesSingleArgument [String]
  | RenderReplTargetProblem [String]
  | GetPkgList String WrapError
  | GatherPkgInfo PackageName VersionRange
  | UnableToParseRepo String
  | NullUnknownrepos [String] [String]
  | UpdateSetupScript
  | InstalledCabalVersion PackageName VersionRange
  | FailNoConfigFile String
  | ParseFailedErr FilePath String String
  | ParseExtraLinesFailedErr String String
  | ParseExtraLinesOkError [PWarning]
  | FetchPackageErr
  | ReportParseResult String FilePath String String
  | ReportSourceRepoProblems String
  | BenchActionException
  | RenderBenchTargetProblem [String]
  | ReportUserTargetProblems [String]
  | ReportUserTargerNonexistantFile [String]
  | ReportUserTargetUnexpectedFile [String]
  | ReportUserTargetUnexpectedUriScheme [String]
  | ReportUserTargetUnrecognisedUri [String]
  | ReadTarballPackageTarget FilePath FilePath
  | ReportPackageTargetProblems [PackageName]
  | PackageNameAmbiguousErr [(PackageName, [PackageName])]
  | ExtractTarballPackageErr String
  | OutdatedAction
  | FreezeFileExistsErr FilePath
  | FinalizePDFailed
  | ProjectTargetSelector String String
  | PhaseRunSolverErr String
  | HaddockCommandDoesn'tSupport
  | CannotParseURIFragment String String
  | MakeDownload URI ByteString ByteString
  | FailedToDownloadURI URI String
  | RemoteRepoCheckHttps String String
  | TransportCheckHttps URI String
  | NoPostYet
  | WGetServerError FilePath String
  | Couldn'tEstablishHttpConnection
  | StatusParseFail URI String
  | TryUpgradeToHttps [String]
  | UnknownHttpTransportSpecified String [String]
  | CmdHaddockReportTargetProblems [String]
  | FailedExtractingScriptBlock String
  | FreezeAction [String]
  | TryFindPackageDescErr String
  | DieIfNotHaddockFailureException String
  | ConfigureInstallInternalError
  | CmdErrorMessages [String]
  | ReportTargetSelectorProblems [String]
  | UnrecognisedTarget [(String, [String], String)]
  | NoSuchTargetSelectorErr [(String, [(Maybe (String, String), String, String, [String])])]
  | TargetSelectorAmbiguousErr [(String, [(String, String)])]
  | TargetSelectorNoCurrentPackageErr String
  | TargetSelectorNoTargetsInCwdTrue
  | TargetSelectorNoTargetsInCwdFalse
  | TargetSelectorNoTargetsInProjectErr
  | TargetSelectorNoScriptErr String
  | MatchingInternalErrorErr String String String [(String, [String])]
  | ReportPlanningFailure String
  | Can'tDownloadPackagesOffline [String]
  | SomePackagesFailedToInstall [(String, String)]
  | PackageDotCabalFileNotFound FilePath
  | PkgConfParsedFailed String
  | BrokenException String
  | WithoutProject String [String]
  | PackagesAlreadyExistInEnvfile FilePath [String]
  | ConfigTests
  | ConfigBenchmarks
  | UnknownPackage String [String]
  | InstallUnitExes String
  | SelectComponentTargetError String
  | SdistActionException [String]
  | Can'tWriteMultipleTarballs
  | ImpossibleHappened String
  | CannotConvertTarballPackage String
  | Win32SelfUpgradeNotNeeded
  | FreezeException String
  | PkgSpecifierException [String]
  | CorruptedIndexCache String
  | UnusableIndexState Repo.RemoteRepo Timestamp Timestamp
  | MissingPackageList Repo.RemoteRepo
  | CmdPathAcceptsNoTargets
  | CmdPathCommandDoesn'tSupportDryRun
  | BadPackageLocations' Doc
  deriving (Show, Typeable)

instance SomeCabalException CabalInstallException where
  getErrorCode e = case e of
    UnpackGet{} -> 7013
    NotTarballDir{} -> 7012
    DirectoryAlreadyExists{} -> 7014
    FileExists{} -> 7015
    FileAlreadyExists{} -> 7016
    DirectoryExists{} -> 7017
    SplitRunArgs{} -> 7018
    CouldNotFindExecutable{} -> 7019
    FoundMultipleMatchingExes{} -> 7020
    NoRemoteRepositories{} -> 7021
    NotATarDotGzFile{} -> 7022
    ExpectedMatchingFileName{} -> 7023
    NoTargetProvided{} -> 7024
    OneTargetRequired{} -> 7025
    ThisIsABug -> 7026
    NoOrMultipleTargetsGiven{} -> 7027
    NoTargetFound{} -> 7028
    MultipleTargetsFound{} -> 7029
    UnexpectedNamedPkgSpecifiers{} -> 7030
    UnexpectedSourcePkgSpecifiers{} -> 7031
    UnableToPerformInplaceUpdate{} -> 7032
    EmptyValuePagerEnvVariable{} -> 7033
    FileDoesntExist{} -> 7034
    ParseError{} -> 7035
    CabalFileNotFound{} -> 7036
    FindOpenProgramLocationErr{} -> 7037
    PkgConfParseFailed{} -> 7038
    ErrorPackingSdist{} -> 7039
    SdistException{} -> 7040
    SpecifyAnExecutable{} -> 7041
    TestCommandDoesn'tSupport{} -> 7042
    ReportTargetProblems{} -> 7043
    ListBinTargetException{} -> 7044
    ResolveWithoutDependency{} -> 7045
    CannotReadCabalFile{} -> 7046
    ErrorUpdatingIndex{} -> 7047
    InternalError{} -> 7048
    ReadIndexCache{} -> 7049
    ConfigStateFileException{} -> 7050
    UploadAction{} -> 7051
    UploadActionDocumentation{} -> 7052
    UploadActionOnlyArchives{} -> 7053
    FileNotFound{} -> 7054
    CheckAction{} -> 7055
    ReportAction{} -> 7056
    InitAction{} -> 7057
    UserConfigAction{} -> 7058
    SpecifySubcommand{} -> 7059
    UnknownUserConfigSubcommand{} -> 7060
    ManpageAction{} -> 7061
    UnrecognizedResponse{} -> 7062
    CheckTarget{} -> 7063
    FetchPackage{} -> 7064
    PlanPackages{} -> 7065
    NoSupportForRunCommand{} -> 7066
    RunPhaseReached{} -> 7067
    UnknownExecutable{} -> 7068
    MultipleMatchingExecutables{} -> 7069
    CmdRunReportTargetProblems{} -> 7070
    CleanAction{} -> 7071
    ReportCannotPruneDependencies{} -> 7072
    ReplCommandDoesn'tSupport{} -> 7073
    ReplTakesNoArguments{} -> 7074
    ReplTakesSingleArgument{} -> 7075
    RenderReplTargetProblem{} -> 7076
    GetPkgList{} -> 7078
    GatherPkgInfo{} -> 7079
    UnableToParseRepo{} -> 7080
    NullUnknownrepos{} -> 7081
    UpdateSetupScript{} -> 7082
    InstalledCabalVersion{} -> 7083
    FailNoConfigFile{} -> 7084
    ParseFailedErr{} -> 7085
    ParseExtraLinesFailedErr{} -> 7087
    ParseExtraLinesOkError{} -> 7088
    FetchPackageErr{} -> 7089
    ReportParseResult{} -> 7090
    ReportSourceRepoProblems{} -> 7091
    BenchActionException{} -> 7092
    RenderBenchTargetProblem{} -> 7093
    ReportUserTargetProblems{} -> 7094
    ReportUserTargerNonexistantFile{} -> 7095
    ReportUserTargetUnexpectedFile{} -> 7096
    ReportUserTargetUnexpectedUriScheme{} -> 7097
    ReportUserTargetUnrecognisedUri{} -> 7098
    ReadTarballPackageTarget{} -> 7099
    ReportPackageTargetProblems{} -> 7100
    PackageNameAmbiguousErr{} -> 7101
    ExtractTarballPackageErr{} -> 7102
    OutdatedAction{} -> 7103
    FreezeFileExistsErr{} -> 7104
    FinalizePDFailed{} -> 7105
    ProjectTargetSelector{} -> 7106
    PhaseRunSolverErr{} -> 7107
    HaddockCommandDoesn'tSupport{} -> 7108
    CannotParseURIFragment{} -> 7109
    MakeDownload{} -> 7110
    FailedToDownloadURI{} -> 7111
    RemoteRepoCheckHttps{} -> 7112
    TransportCheckHttps{} -> 7113
    NoPostYet{} -> 7114
    WGetServerError{} -> 7115
    Couldn'tEstablishHttpConnection{} -> 7116
    StatusParseFail{} -> 7117
    TryUpgradeToHttps{} -> 7118
    UnknownHttpTransportSpecified{} -> 7119
    CmdHaddockReportTargetProblems{} -> 7120
    FailedExtractingScriptBlock{} -> 7121
    FreezeAction{} -> 7122
    TryFindPackageDescErr{} -> 7124
    DieIfNotHaddockFailureException{} -> 7125
    ConfigureInstallInternalError{} -> 7126
    CmdErrorMessages{} -> 7127
    ReportTargetSelectorProblems{} -> 7128
    UnrecognisedTarget{} -> 7129
    NoSuchTargetSelectorErr{} -> 7131
    TargetSelectorAmbiguousErr{} -> 7132
    TargetSelectorNoCurrentPackageErr{} -> 7133
    TargetSelectorNoTargetsInCwdTrue{} -> 7134
    TargetSelectorNoTargetsInCwdFalse{} -> 7135
    TargetSelectorNoTargetsInProjectErr{} -> 7136
    TargetSelectorNoScriptErr{} -> 7137
    MatchingInternalErrorErr{} -> 7130
    ReportPlanningFailure{} -> 7138
    Can'tDownloadPackagesOffline{} -> 7139
    SomePackagesFailedToInstall{} -> 7140
    PackageDotCabalFileNotFound{} -> 7141
    PkgConfParsedFailed{} -> 7142
    BrokenException{} -> 7143
    WithoutProject{} -> 7144
    PackagesAlreadyExistInEnvfile{} -> 7145
    ConfigTests{} -> 7146
    ConfigBenchmarks{} -> 7147
    UnknownPackage{} -> 7148
    InstallUnitExes{} -> 7149
    SelectComponentTargetError{} -> 7150
    SdistActionException{} -> 7151
    Can'tWriteMultipleTarballs{} -> 7152
    ImpossibleHappened{} -> 7153
    CannotConvertTarballPackage{} -> 7154
    Win32SelfUpgradeNotNeeded{} -> 7155
    FreezeException{} -> 7156
    PkgSpecifierException{} -> 7157
    CorruptedIndexCache{} -> 7158
    UnusableIndexState{} -> 7159
    MissingPackageList{} -> 7160
    CmdPathAcceptsNoTargets{} -> 7161
    CmdPathCommandDoesn'tSupportDryRun -> 7163
    BadPackageLocations'{} -> 7164

instance Pretty CabalInstallException where
  pretty e = case e of
    UnpackGet ->
      text $
        "The 'get' command does no yet support targets "
          ++ "that are remote source repositories."
    NotTarballDir t ->
      text $
        "The 'get' command is for tarball packages. "
          ++ "The target '"
          ++ t
          ++ "' is not a tarball."
    DirectoryAlreadyExists pkgdir' -> text $ "The directory \"" ++ pkgdir' ++ "\" already exists and is not empty, not unpacking."
    FileExists pkgdir -> text $ "A file \"" ++ pkgdir ++ "\" is in the way, not unpacking."
    FileAlreadyExists pkgFile -> text $ "The file \"" ++ pkgFile ++ "\" already exists, not overwriting."
    DirectoryExists pkgFile -> text $ "A directory \"" ++ pkgFile ++ "\" is in the way, not unpacking."
    SplitRunArgs err -> text $ err
    CouldNotFindExecutable -> text $ "run: Could not find executable in LocalBuildInfo"
    FoundMultipleMatchingExes -> text $ "run: Found multiple matching exes in LocalBuildInfo"
    NoRemoteRepositories -> text $ "Cannot upload. No remote repositories are configured."
    NotATarDotGzFile paths -> text $ "Not a tar.gz file: " ++ paths
    ExpectedMatchingFileName -> text $ "Expected a file name matching the pattern <pkgid>-docs.tar.gz"
    NoTargetProvided -> text $ "One target is required, none provided"
    OneTargetRequired -> text $ "One target is required, given multiple"
    ThisIsABug ->
      text $
        "No or multiple targets given, but the run "
          ++ "phase has been reached. This is a bug."
    NoOrMultipleTargetsGiven -> text $ "No or multiple targets given..."
    NoTargetFound -> text $ "No target found"
    MultipleTargetsFound -> text $ "Multiple targets found"
    UnexpectedNamedPkgSpecifiers ->
      text $
        "internal error: 'resolveUserTargets' returned "
          ++ "unexpected named package specifiers!"
    UnexpectedSourcePkgSpecifiers ->
      text $
        "internal error: 'resolveUserTargets' returned "
          ++ "unexpected source package specifiers!"
    UnableToPerformInplaceUpdate -> text $ "local project file has conditional and/or import logic, unable to perform and automatic in-place update"
    EmptyValuePagerEnvVariable -> text $ "man: empty value of the PAGER environment variable"
    FileDoesntExist fpath -> text $ "Error Parsing: file \"" ++ fpath ++ "\" doesn't exist. Cannot continue."
    ParseError -> text $ "parse error"
    CabalFileNotFound cabalFile -> text $ "Package .cabal file not found in the tarball: " ++ cabalFile
    FindOpenProgramLocationErr err -> text $ err
    PkgConfParseFailed perror ->
      text $
        "Couldn't parse the output of 'setup register --gen-pkg-config':"
          ++ show perror
    ErrorPackingSdist err -> text $ "Error packing sdist: " ++ err
    SdistException pkgIdentifier -> text $ "sdist of " ++ prettyShow pkgIdentifier
    SpecifyAnExecutable -> text $ "Please specify an executable to run"
    TestCommandDoesn'tSupport ->
      text $
        "The test command does not support '--only-dependencies'. "
          ++ "You may wish to use 'build --only-dependencies' and then "
          ++ "use 'test'."
    ReportTargetProblems problemsMsg -> text $ problemsMsg
    ListBinTargetException errorStr -> text $ errorStr
    ResolveWithoutDependency errorStr -> text $ errorStr
    CannotReadCabalFile file -> text $ "Cannot read .cabal file inside " ++ file
    ErrorUpdatingIndex name ioe -> text $ "Error while updating index for " ++ name ++ " repository " ++ show ioe
    InternalError msg ->
      text $
        "internal error when reading package index: "
          ++ msg
          ++ "The package index or index cache is probably "
          ++ "corrupt. Running cabal update might fix it."
    ReadIndexCache paths -> text $ show (paths)
    ConfigStateFileException err -> text $ err
    UploadAction -> text $ "the 'upload' command expects at least one .tar.gz archive."
    UploadActionDocumentation ->
      text $
        "the 'upload' command can only upload documentation "
          ++ "for one package at a time."
    UploadActionOnlyArchives otherFiles ->
      text $
        "the 'upload' command expects only .tar.gz archives: "
          ++ intercalate ", " otherFiles
    FileNotFound tarfile -> text $ "file not found: " ++ tarfile
    CheckAction extraArgs -> text $ "'check' doesn't take any extra arguments: " ++ unwords extraArgs
    ReportAction extraArgs -> text $ "'report' doesn't take any extra arguments: " ++ unwords extraArgs
    InitAction ->
      text $
        "'init' only takes a single, optional, extra "
          ++ "argument for the project root directory"
    UserConfigAction paths -> text $ paths ++ " already exists."
    SpecifySubcommand -> text $ "Please specify a subcommand (see 'help user-config')"
    UnknownUserConfigSubcommand extraArgs -> text $ "Unknown 'user-config' subcommand: " ++ unwords extraArgs
    ManpageAction extraArgs -> text $ "'man' doesn't take any extra arguments: " ++ unwords extraArgs
    UnrecognizedResponse -> text $ "unrecognized response"
    CheckTarget ->
      text $
        "The 'fetch' command does not yet support remote tarballs. "
          ++ "In the meantime you can use the 'get' commands."
    FetchPackage ->
      text $
        "The 'fetch' command does not yet support remote "
          ++ "source repositories."
    PlanPackages errorStr -> text $ errorStr
    NoSupportForRunCommand ->
      text $
        "The run command does not support '--only-dependencies'. "
          ++ "You may wish to use 'build --only-dependencies' and then "
          ++ "use 'run'."
    RunPhaseReached ->
      text $
        "No or multiple targets given, but the run "
          ++ "phase has been reached. This is a bug."
    UnknownExecutable exeName selectedUnitId ->
      text $
        "Unknown executable "
          ++ exeName
          ++ " in package "
          ++ prettyShow selectedUnitId
    MultipleMatchingExecutables exeName elabUnitId ->
      text $
        "Multiple matching executables found matching "
          ++ exeName
          ++ ":\n"
          ++ unlines elabUnitId
    CmdRunReportTargetProblems renderProb -> text $ renderProb
    CleanAction notScripts ->
      text $
        "'clean' extra arguments should be script files: "
          ++ unwords notScripts
    ReportCannotPruneDependencies renderCannotPruneDependencies -> text $ renderCannotPruneDependencies
    ReplCommandDoesn'tSupport ->
      text $
        "The repl command does not support '--only-dependencies'. "
          ++ "You may wish to use 'build --only-dependencies' and then "
          ++ "use 'repl'."
    ReplTakesNoArguments targetStrings -> text $ "'repl' takes no arguments or a script argument outside a project: " ++ unwords targetStrings
    ReplTakesSingleArgument targetStrings -> text $ "'repl' takes a single argument which should be a script: " ++ unwords targetStrings
    RenderReplTargetProblem renderProblem -> text $ unlines renderProblem
    GetPkgList pat err -> text $ "Failed to compile regex " ++ pat ++ ": " ++ snd err
    GatherPkgInfo name verConstraint ->
      text $
        "There is no available version of "
          ++ prettyShow name
          ++ " that satisfies "
          ++ prettyShow verConstraint
    UnableToParseRepo s -> text $ "'v2-update' unable to parse repo: \"" ++ s ++ "\""
    NullUnknownrepos unRepoName remoteRepoNames ->
      text $
        "'v2-update' repo(s): \""
          ++ intercalate "\", \"" unRepoName
          ++ "\" can not be found in known remote repo(s): "
          ++ intercalate ", " remoteRepoNames
    UpdateSetupScript -> text $ "Using 'build-type: Custom' but there is no Setup.hs or Setup.lhs script."
    InstalledCabalVersion name verRange ->
      text $
        "The package '"
          ++ prettyShow name
          ++ "' requires Cabal library version "
          ++ prettyShow verRange
          ++ " but no suitable version is installed."
    FailNoConfigFile msgNotFound ->
      text $
        unlines
          [ msgNotFound
          , "(Config files can be created via the cabal-command 'user-config init'.)"
          ]
    ParseFailedErr configFile msg line ->
      text $
        "Error parsing config file "
          ++ configFile
          ++ line
          ++ ":\n"
          ++ msg
    ParseExtraLinesFailedErr msg line ->
      text $
        "Error parsing additional config lines\n"
          ++ line
          ++ ":\n"
          ++ msg
    ParseExtraLinesOkError ws -> text $ unlines (map (showPWarning "Error parsing additional config lines") ws)
    FetchPackageErr -> text $ "fetchPackage: source repos not supported"
    ReportParseResult filetype filename line msg ->
      text $
        "Error parsing "
          ++ filetype
          ++ " "
          ++ filename
          ++ line
          ++ ":\n"
          ++ msg
    ReportSourceRepoProblems errorStr -> text $ errorStr
    BenchActionException ->
      text $
        "The bench command does not support '--only-dependencies'. "
          ++ "You may wish to use 'build --only-dependencies' and then "
          ++ "use 'bench'."
    RenderBenchTargetProblem errorStr -> text $ unlines errorStr
    ReportUserTargetProblems target ->
      text $
        unlines
          [ "Unrecognised target '" ++ name ++ "'."
          | name <- target
          ]
          ++ "Targets can be:\n"
          ++ " - package names, e.g. 'pkgname', 'pkgname-1.0.1', 'pkgname < 2.0'\n"
          ++ " - cabal files 'pkgname.cabal' or package directories 'pkgname/'\n"
          ++ " - package tarballs 'pkgname.tar.gz' or 'http://example.com/pkgname.tar.gz'"
    ReportUserTargerNonexistantFile target ->
      text $
        unlines
          [ "The file does not exist '" ++ name ++ "'."
          | name <- target
          ]
    ReportUserTargetUnexpectedFile target ->
      text $
        unlines
          [ "Unrecognised file target '" ++ name ++ "'."
          | name <- target
          ]
          ++ "File targets can be either package tarballs 'pkgname.tar.gz' "
          ++ "or cabal files 'pkgname.cabal'."
    ReportUserTargetUnexpectedUriScheme target ->
      text $
        unlines
          [ "URL target not supported '" ++ name ++ "'."
          | name <- target
          ]
          ++ "Only 'http://' and 'https://' URLs are supported."
    ReportUserTargetUnrecognisedUri target ->
      text $
        unlines
          [ "Unrecognise URL target '" ++ name ++ "'."
          | name <- target
          ]
    ReadTarballPackageTarget filename tarballFile ->
      text $
        "Could not parse the cabal file "
          ++ filename
          ++ " in "
          ++ tarballFile
    ReportPackageTargetProblems pkgs ->
      text $
        unlines
          [ "There is no package named '" ++ prettyShow name ++ "'. "
          | name <- pkgs
          ]
          ++ "You may need to run 'cabal update' to get the latest "
          ++ "list of available packages."
    PackageNameAmbiguousErr ambiguities ->
      text $
        unlines
          [ "There is no package named '"
            ++ prettyShow name
            ++ "'. "
            ++ ( if length matches > 1
                  then "However, the following package names exist: "
                  else "However, the following package name exists: "
               )
            ++ intercalate ", " ["'" ++ prettyShow m ++ "'" | m <- matches]
            ++ "."
          | (name, matches) <- ambiguities
          ]
    ExtractTarballPackageErr err -> text $ err
    OutdatedAction -> text $ "--project-dir and --project-file must only be used with --v2-freeze-file."
    FreezeFileExistsErr freezeFile ->
      text $
        "Couldn't find a freeze file expected at: "
          ++ freezeFile
          ++ "\n\n"
          ++ "We are looking for this file because you supplied '--project-file' or '--v2-freeze-file'. "
          ++ "When one of these flags is given, we try to read the dependencies from a freeze file. "
          ++ "If it is undesired behaviour, you should not use these flags, otherwise please generate "
          ++ "a freeze file via 'cabal freeze'."
    FinalizePDFailed -> text $ "finalizePD failed"
    ProjectTargetSelector input err -> text $ "Invalid package ID: " ++ input ++ "\n" ++ err
    PhaseRunSolverErr msg -> text $ msg
    HaddockCommandDoesn'tSupport -> text $ "The haddock command does not support '--only-dependencies'."
    CannotParseURIFragment uriFrag err -> text $ "Cannot parse URI fragment " ++ uriFrag ++ " " ++ err
    MakeDownload uri expected actual ->
      text $
        unwords
          [ "Failed to download"
          , show uri
          , ": SHA256 don't match; expected:"
          , BS8.unpack (Base16.encode expected)
          , "actual:"
          , BS8.unpack (Base16.encode actual)
          ]
    FailedToDownloadURI uri errCode ->
      text $
        "failed to download "
          ++ show uri
          ++ " : HTTP code "
          ++ errCode
    RemoteRepoCheckHttps unRepoName requiresHttpsErrorMessage ->
      text $
        "The remote repository '"
          ++ unRepoName
          ++ "' specifies a URL that "
          ++ requiresHttpsErrorMessage
    TransportCheckHttps uri requiresHttpsErrorMessage ->
      text $
        "The URL "
          ++ show uri
          ++ " "
          ++ requiresHttpsErrorMessage
    NoPostYet -> text $ "Posting (for report upload) is not implemented yet"
    WGetServerError programPath resp ->
      text $
        "'"
          ++ programPath
          ++ "' exited with an error:\n"
          ++ resp
    Couldn'tEstablishHttpConnection ->
      text $
        "Couldn't establish HTTP connection. "
          ++ "Possible cause: HTTP proxy server is down."
    StatusParseFail uri r ->
      text $
        "Failed to download "
          ++ show uri
          ++ " : "
          ++ "No Status Code could be parsed from response: "
          ++ r
    TryUpgradeToHttps str ->
      text $
        "The builtin HTTP implementation does not support HTTPS, but using "
          ++ "HTTPS for authenticated uploads is recommended. "
          ++ "The transport implementations with HTTPS support are "
          ++ intercalate ", " str
          ++ "but they require the corresponding external program to be "
          ++ "available. You can either make one available or use plain HTTP by "
          ++ "using the global flag --http-transport=plain-http (or putting the "
          ++ "equivalent in the config file). With plain HTTP, your password "
          ++ "is sent using HTTP digest authentication so it cannot be easily "
          ++ "intercepted, but it is not as secure as using HTTPS."
    UnknownHttpTransportSpecified name str ->
      text $
        "Unknown HTTP transport specified: "
          ++ name
          ++ ". The supported transports are "
          ++ intercalate
            ", "
            str
    CmdHaddockReportTargetProblems str -> text $ unlines str
    FailedExtractingScriptBlock eStr -> text $ "Failed extracting script block: " ++ eStr
    FreezeAction extraArgs ->
      text $
        "'freeze' doesn't take any extra arguments: "
          ++ unwords extraArgs
    TryFindPackageDescErr err -> text $ err
    DieIfNotHaddockFailureException errorStr -> text $ errorStr
    ConfigureInstallInternalError ->
      text $
        "internal error: configure install plan should have exactly "
          ++ "one local ready package."
    CmdErrorMessages err -> text $ unlines err
    ReportTargetSelectorProblems targets ->
      text $
        unlines
          [ "Unrecognised target syntax for '" ++ name ++ "'."
          | name <- targets
          ]
    UnrecognisedTarget targets ->
      text $
        unlines
          [ "Unrecognised target '"
            ++ target
            ++ "'.\n"
            ++ "Expected a "
            ++ intercalate " or " expected
            ++ ", rather than '"
            ++ got
            ++ "'."
          | (target, expected, got) <- targets
          ]
    NoSuchTargetSelectorErr targets ->
      text $
        unlines
          [ "Unknown target '"
            ++ target
            ++ "'.\n"
            ++ unlines
              [ ( case inside of
                    Just (kind, "") ->
                      "The " ++ kind ++ " has no "
                    Just (kind, thing) ->
                      "The " ++ kind ++ " " ++ thing ++ " has no "
                    Nothing -> "There is no "
                )
                ++ intercalate
                  " or "
                  [ mungeThing thing ++ " '" ++ got ++ "'"
                  | (thing, got, _alts) <- nosuch'
                  ]
                ++ "."
                ++ if null alternatives
                  then ""
                  else
                    "\nPerhaps you meant "
                      ++ intercalate
                        ";\nor "
                        [ "the " ++ thing ++ " '" ++ intercalate "' or '" alts ++ "'?"
                        | (thing, alts) <- alternatives
                        ]
              | (inside, nosuch') <- groupByContainer nosuch
              , let alternatives =
                      [ (thing, alts)
                      | (thing, _got, alts@(_ : _)) <- nosuch'
                      ]
              ]
          | (target, nosuch) <- targets
          , let groupByContainer =
                  map
                    ( \g@((inside, _, _, _) : _) ->
                        ( inside
                        , [ (thing, got, alts)
                          | (_, thing, got, alts) <- g
                          ]
                        )
                    )
                    . groupBy ((==) `on` (\(x, _, _, _) -> x))
                    . sortBy (compare `on` (\(x, _, _, _) -> x))
          ]
      where
        mungeThing "file" = "file target"
        mungeThing thing = thing
    TargetSelectorAmbiguousErr targets ->
      text $
        unlines
          [ "Ambiguous target '"
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
    TargetSelectorNoCurrentPackageErr target ->
      text $
        "The target '"
          ++ target
          ++ "' refers to the "
          ++ "components in the package in the current directory, but there "
          ++ "is no package in the current directory (or at least not listed "
          ++ "as part of the project)."
    TargetSelectorNoTargetsInCwdTrue ->
      text $
        "No targets given and there is no package in the current "
          ++ "directory. Use the target 'all' for all packages in the "
          ++ "project or specify packages or components by name or location. "
          ++ "See 'cabal build --help' for more details on target options."
    TargetSelectorNoTargetsInCwdFalse ->
      text $
        "No targets given and there is no package in the current "
          ++ "directory. Specify packages or components by name or location. "
          ++ "See 'cabal build --help' for more details on target options."
    TargetSelectorNoTargetsInProjectErr ->
      text $
        "There is no <pkgname>.cabal package file or cabal.project file. "
          ++ "To build packages locally you need at minimum a <pkgname>.cabal "
          ++ "file. You can use 'cabal init' to create one.\n"
          ++ "\n"
          ++ "For non-trivial projects you will also want a cabal.project "
          ++ "file in the root directory of your project. This file lists the "
          ++ "packages in your project and all other build configuration. "
          ++ "See the Cabal user guide for full details."
    TargetSelectorNoScriptErr target ->
      text $
        "The script '"
          ++ target
          ++ "' does not exist, "
          ++ "and only script targets may contain whitespace characters or end "
          ++ "with ':'"
    MatchingInternalErrorErr t s sKind renderingsAndMatches ->
      text $
        "Internal error in target matching: could not make an "
          ++ "unambiguous fully qualified target selector for '"
          ++ t
          ++ "'.\n"
          ++ "We made the target '"
          ++ s
          ++ "' ("
          ++ sKind
          ++ ") that was expected to "
          ++ "be unambiguous but matches the following targets:\n"
          ++ unlines
            [ "'"
              ++ rendering
              ++ "', matching:"
              ++ concatMap
                ("\n  - " ++)
                matches
            | (rendering, matches) <- renderingsAndMatches
            ]
          ++ "\nNote: Cabal expects to be able to make a single fully "
          ++ "qualified name for a target or provide a more specific error. "
          ++ "Our failure to do so is a bug in cabal. "
          ++ "Tracking issue: https://github.com/haskell/cabal/issues/8684"
          ++ "\n\nHint: this may be caused by trying to build a package that "
          ++ "exists in the project directory but is missing from "
          ++ "the 'packages' stanza in your cabal project file."
    ReportPlanningFailure message -> text $ message
    Can'tDownloadPackagesOffline notFetched ->
      text $
        "Can't download packages in offline mode. "
          ++ "Must download the following packages to proceed:\n"
          ++ intercalate ", " notFetched
          ++ "\nTry using 'cabal fetch'."
    SomePackagesFailedToInstall failed ->
      text $
        unlines $
          "Some packages failed to install:"
            : [ pkgid ++ reason
              | (pkgid, reason) <- failed
              ]
    PackageDotCabalFileNotFound descFilePath -> text $ "Package .cabal file not found: " ++ show descFilePath
    PkgConfParsedFailed perror ->
      text $
        "Couldn't parse the output of 'setup register --gen-pkg-config':"
          ++ show perror
    BrokenException errorStr -> text $ errorStr
    WithoutProject str1 str2 ->
      text $
        concat $
          [ "Unknown package \""
          , str1
          , "\". "
          ]
            ++ str2
    PackagesAlreadyExistInEnvfile envFile name ->
      text $
        "Packages requested to install already exist in environment file at "
          ++ envFile
          ++ ". Overwriting them may break other packages. Use --force-reinstalls to proceed anyway. Packages: "
          ++ intercalate ", " name
    ConfigTests ->
      text $
        "--enable-tests was specified, but tests can't "
          ++ "be enabled in a remote package"
    ConfigBenchmarks ->
      text $
        "--enable-benchmarks was specified, but benchmarks can't "
          ++ "be enabled in a remote package"
    UnknownPackage hn name ->
      text $
        concat $
          [ "Unknown package \""
          , hn
          , "\". "
          , "Did you mean any of the following?\n"
          , unlines name
          ]
    InstallUnitExes errorMessage -> text $ errorMessage
    SelectComponentTargetError errorMessage -> text $ errorMessage
    SdistActionException errs -> text $ unlines errs
    Can'tWriteMultipleTarballs -> text $ "Can't write multiple tarballs to standard output!"
    ImpossibleHappened pkg -> text $ "The impossible happened: a local package isn't local" ++ pkg
    CannotConvertTarballPackage format -> text $ "cannot convert tarball package to " ++ format
    Win32SelfUpgradeNotNeeded -> text $ "win32selfupgrade not needed except on win32"
    FreezeException errs -> text $ errs
    PkgSpecifierException errorStr -> text $ unlines errorStr
    CorruptedIndexCache str -> text $ str
    UnusableIndexState repoRemote maxFound requested ->
      text $
        "Latest known index-state for '"
          ++ RepoName.unRepoName (Repo.remoteRepoName repoRemote)
          ++ "' ("
          ++ prettyShow maxFound
          ++ ") is older than the requested index-state ("
          ++ prettyShow requested
          ++ ").\nRun 'cabal update' or set the index-state to a value at or before "
          ++ prettyShow maxFound
          ++ "."
    MissingPackageList repoRemote ->
      text $
        "The package list for '"
          ++ RepoName.unRepoName (Repo.remoteRepoName repoRemote)
          ++ "' does not exist. Run 'cabal update' to download it."
    CmdPathAcceptsNoTargets ->
      text $
        "The 'path' command accepts no target arguments."
    CmdPathCommandDoesn'tSupportDryRun ->
      text $
        "The 'path' command doesn't support the flag '--dry-run'."
    BadPackageLocations' message -> message

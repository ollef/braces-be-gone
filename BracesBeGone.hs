#!/usr/bin/env stack
-- stack --resolver lts-8.0 --install-ghc runghc --package text --package optparse-applicative
{-# LANGUAGE OverloadedStrings #-}
module BeGone where

import qualified Data.Char as Char
import qualified Data.Foldable as Foldable
import Data.Monoid
import Data.Text(Text)
import qualified Data.Text as Text
import qualified Data.Text.IO as Text
import Options.Applicative
import System.IO

main :: IO ()
main = do
  options <- execParser optionsParserInfo
  withMaybeFile (inputFile options) ReadMode stdin $ \inputHandle ->
    withMaybeFile (outputFile options) WriteMode stdout $ \outputHandle -> do
      input <- Text.hGetContents inputHandle
      Text.hPutStr outputHandle $ bracesBeGone options input
  where
    withMaybeFile Nothing _ def k = k def
    withMaybeFile (Just filePath) mode def k = withFile filePath mode k

-------------------------------------------------------------------------------
-- * Command-line options and stuff
data Options = Options
  { inputFile :: Maybe FilePath
  , outputFile :: Maybe FilePath
  , tabWidth :: Int
  , minLineWidth :: Int
  , braceChars :: String
  } deriving (Show)

optionsParserInfo :: ParserInfo Options
optionsParserInfo = info (helper <*> optionsParser)
  $ fullDesc <> header "Braces Be Gone"

optionsParser :: Parser Options
optionsParser = Options
  <$> optional (strArgument
    $ metavar "FILE"
    <> help "Input source FILE (default: stdin)"
    <> action "file"
    )
  <*> optional (strOption
    $ long "output"
    <> short 'o'
    <> metavar "FILE"
    <> help "Write output to FILE (default: stdout)"
    <> action "file"
    )
  <*> option auto
    (long "tab-width"
    <> metavar "TABWIDTH"
    <> help "Count tab characters as TABWIDTH spaces (default: 8)"
    <> value 8
    )
  <*> option auto
    (long "min-line-width"
    <> metavar "LINEWIDTH"
    <> help "Align braces at least to LINEWIDTH (default: 0)"
    <> value 0
    )
  <*> strOption
    (long "brace-chars"
    <> metavar "CHARS"
    <> help "Use CHARS as braces (default: \"{};\")"
    <> value "{};"
    )

-------------------------------------------------------------------------------
-- * Here's where the magic happens
bracesBeGone :: Options -> Text -> Text
bracesBeGone options input = Text.unlines paddedLines
  where
    brokenLines = joinBraceLines $ breakUpLine options <$> Text.lines input
    width = maximum $ visualWidth options . fst <$> brokenLines
    paddedLines
      = uncurry (pad options $ max (width + 1) $ minLineWidth options)
      <$> brokenLines

spanEnd :: (Char -> Bool) -> Text -> (Text, Text)
spanEnd p s = (Text.dropWhileEnd p s, Text.takeWhileEnd p s)

breakUpLine :: Options -> Text -> (Text, Text)
breakUpLine options line = (code, Text.filter (not . Char.isSpace) braces)
  where
    (code, braces)
      = spanEnd (\c -> Char.isSpace c || c `elem` braceChars options) line

allSpaces :: Text -> Bool
allSpaces = Text.all Char.isSpace

joinBraceLines :: [(Text, Text)] -> [(Text, Text)]
joinBraceLines = reverse . Foldable.foldl' go []
  where
    go results (code, braces)
      | allSpaces code
      , not (allSpaces braces)
      , (lastCode, lastBraces):results' <- results
      , not (allSpaces lastCode)
      = (lastCode, lastBraces <> braces) : results'
      | otherwise
      = (code, braces) : results

pad :: Options -> Int -> Text -> Text -> Text
pad options width code braces
  | allSpaces braces = code
  | otherwise
  = code
  <> Text.replicate (width - visualWidth options code) " "
  <> braces

visualWidth :: Options -> Text -> Int
visualWidth options s = Text.length s + Text.count "\t" s * (tabWidth options - 1)

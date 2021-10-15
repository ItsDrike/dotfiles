-- Base
import XMonad
import System.Exit (exitSuccess)
import System.IO (hPutStrLn, Handle)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WithAll (sinkAll, killAll)

-- Data
import Data.Maybe (isJust, fromJust)
import Data.Monoid
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)

-- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ResizableTile

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange)
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce

-----------------------------------------------------------------------------
-- Basic settings:

-- Set the modkey
-- mod1Mask: left alt, mod4Mask: super key.
myModMask :: KeyMask
myModMask = mod4Mask

-- Preferred programs
myTerminal = "alacritty"
myBrowser = "firefox"

-- Preferred font
myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

-- Width of the window border in pixels
myBorderWidth :: Dimension
myBorderWidth = 2

-- Border color of normal windows
myNormalBorderColor :: String
myNormalBorderColor = "#3b4252"

-- Border color of focused windows
myFocusedBorderColor :: String
myFocusedBorderColor = "#bc96da"

-- Default workspaces. Number of workspaces is determined by the list length.
myWorkspaces = [" dev ", " www ", " sys ", " chat ", " mus ", " vid ", " doc ", " virt ", " etc "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

-- Make the workspaces clickable
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

-- Keep track of the number of windows in current workspace
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


-------------------------------------------------------------------------------
-- Key bindings with EZConfig:
-- C: Ctrl, S: Shift, M: Mod, M1: Alt

myKeys :: [(String, X ())]
myKeys =
    -- XMonad
    [ ("M-S-r", spawn "xmonad --recompile; xmonad --restart")   -- Recompiles xmonad
    , ("M-S-q", io exitSuccess)                                 -- Quits xmonad

    -- Lock screen
    , ("C-M-l", spawn "xsecurelock") -- XSecureLock lockscreen
    --, ("C-M-l", spawn "xset s activate") -- Send DPMS trigger for lockscreen

    -- Programs
    , ("M-b",           spawn (myBrowser))
    , ("M-<Return>",    spawn (myTerminal))
    , ("M-M1-h",        spawn (myTerminal ++ " -e htop"))
    , ("M-M1-b",        spawn (myTerminal ++ " -e bpytop"))
    , ("M-M1-p",        spawn (myTerminal ++ " -e ipython"))

    -- Dmenu
    , ("M-S-<Return>", spawn "dmenu_run -i -p \"Run: \"")

    -- Screenshots
    , ("<Print>",       spawn "flameshot gui")
    , ("M-<Print>",     spawn "flameshot screen -p ~/Pictures/Screenshots")
    , ("M-S-<Print>",   spawn "flameshot screen -c")
    , ("C-<Print>",     spawn "flameshot full -p ~/Pictures/Screenshots")
    , ("C-S-<Print>",   spawn "flameshot full -c")
    , ("C-M-<Print>",   spawn "flameshot launcher")

    -- Script shortcuts
    , ("M-S-p",         spawn "setbg ~/Pictures/Wallpapers/Active")  -- Set random background
    , ("M-S-d",         spawn "displayselect")

    -- Kill windows
    , ("M-w", kill1)        -- Kill the currently focused client
    , ("M-S-w", killAll)    -- Kill all windows on current workspace

    -- Compositor
    , ("M-C-x",     spawn "picom -b")       -- Run picom compositor
    , ("M-S-x",     spawn "killall picom")  -- Kill picom compositor

    -- Workspaces
    , ("M-.", nextScreen)   -- Switch focus to next monitor
    , ("M-,", prevScreen)   -- Switch focus to prev monitor
    , ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next ws
    , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to prev ws

    -- Floating windows
    , ("M-f",   withFocused $ float)                -- Make window float
    , ("M-t",   withFocused $ windows . W.sink)     -- Push floating window back to tile
    , ("M-S-t", sinkAll)                            -- Push all floating windows to tile
    , ("M-S-f", sendMessage (T.Toggle "floats"))    -- Toggles 'floats' layout

    -- Increase/decrease spacing (gaps)
    , ("C-M1-j", decWindowSpacing 4)    -- Decrease window spacing
    , ("C-M1-k", incWindowSpacing 4)    -- Increase window spacing
    , ("C-M1-h", decScreenSpacing 4)    -- Decrease screen spacing
    , ("C-M1-l", incScreenSpacing 4)    -- Increase screen spacing

    -- Windows navigation
    , ("M-m",       windows W.focusMaster)  -- Move focus to the master window
    , ("M-j",       windows W.focusDown)    -- Move focus to the next window
    , ("M-k",       windows W.focusUp)      -- Move focus to the prev window
    , ("M-S-m",     windows W.swapMaster)   -- Swap the focused window and the master window
    , ("M-S-j",     windows W.swapDown)     -- Swap focused window with next window
    , ("M-S-k",     windows W.swapUp)       -- Swap focused window with prev window
    , ("M-S-<Tab>", rotSlavesDown)          -- Rotate all windows except master and keep focus in place
    , ("M-C-<Tab>", rotAllDown)             -- Rotate all windows in the current stack
    , ("M-<Backspace>", promote)            -- Moves focused window to master, others maintain order

    -- Layouts
    , ("M-<Tab>",   sendMessage NextLayout)   -- Switch to next layout
    , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full

    -- Increase/decrease windows in the master pane or the stack
    , ("M-S-<Up>",      sendMessage (IncMasterN 1))     -- Increase # of clients master pane
    , ("M-S-<Down>",    sendMessage (IncMasterN (-1)))  -- Decrease # of clients master pane
    , ("M-C-<Up>",      increaseLimit)                  -- Increase # of windows
    , ("M-C-<Down>",    decreaseLimit)                  -- Decrease # of windows

    -- Window resizing
    , ("M-h",       sendMessage Shrink)         -- Shrink horiz window width
    , ("M-l",       sendMessage Expand)         -- Expand horiz window width
    , ("M-M1-j",    sendMessage MirrorShrink)   -- Shrink vert window width
    , ("M-M1-k",    sendMessage MirrorExpand)   -- Expand vert window width

    -- Multimedia keys
    , ("<XF86AudioMute>",           spawn "pulsemixer --toggle-mute")
    , ("<XF86AudioLowerVolume>",    spawn "pulsemixer --change-volume -5")
    , ("<XF86AudioRaiseVolume>",    spawn "pulsemixer --change-volume +5")
    , ("<XF86MonBrightnessUp>",     spawn "brightness + 5 %")
    , ("<XF86MonBrightnessDown>",   spawn "brightness - 5 %")
    -- Map media keys to meta + arrows for keyboards without special keys
    , ("M-<Down>",                  spawn "pulsemixer --change-volume -5")
    , ("M-<Up>",                    spawn "pulsemixer --change-volume +5")
    , ("M-<Right>",                 spawn "brightness + 5 %")
    , ("M-<Left>",                  spawn "brightness - 5 %")
    ]
        where nonNSP            = WSIs (return (\ws -> W.tag ws /= "NSP"))
              nonEmptyNonNSP    = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

-------------------------------------------------------------------------------
-- Layout vars:

--Makes setting the spacingRaw simpler to write.
--The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1c1f24"
    , swn_color             = "#ffffff"
    }

-------------------------------------------------------------------------------
-- Layouts:
-- All of these layouts have to be defined in myLayoutHook, otherwise
-- type errors will occur

tall     = renamed [Replace "tall"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 8
           $ spiral (6/7)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme


myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth tall
                                 ||| magnify
                                 ||| floats
                                 ||| grid
                                 ||| spirals
                                 ||| tabs

-------------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
-- `doFloat` forces a window to float, useful for dialog boxes and such.
-- `doShift (myWorkspaces !! 7)` sends program to workspace 8

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
    -- Make dialog boxes floating, don't tile them
    [ className =? "notification"       --> doFloat
    , className =? "confirm"            --> doFloat
    , className =? "dialog"             --> doFloat
    , className =? "error"              --> doFloat
    , className =? "download"           --> doFloat
    , className =? "file_progress"      --> doFloat
    , className =? "splash"             --> doFloat
    , className =? "toolbar"            --> doFloat
    , className =? "Qalculate-gtk"      --> doFloat
    , className =? "udiskie"            --> doFloat
    , isFullscreen                      --> doFullFloat
    -- auto-shift applications to their respecitve workspaces
    , className =? "discord"            --> doShift ( myWorkspaces !! 3 )
    , className =? "Element"            --> doShift ( myWorkspaces !! 3 )
    , className =? "Code"               --> doShift ( myWorkspaces !! 0 )
    , className =? "Stremio"		--> doShift ( myWorkspaces !! 5 )
    , title     =? "Mozilla Firefox"    --> doShift ( myWorkspaces !! 1 )
    ]

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- I don't really use this because I define these applications
-- in ~/.config/x11/xprofile instead, that way it will apply for
-- all WMs, not just for XMonad

myStartupHook :: X ()
myStartupHook = do
    -- Automatically run autostart.sh script which will start
    -- .desktop applications defined in ~/.config/autostart
    spawnOnce "$HOME/.config/xmonad/scripts/autostart.sh &"

-------------------------------------------------------------------------------
-- Log hook: this sends info to xmobar process(es)

myLogHook :: Handle -> Handle -> X ()
myLogHook xmproc0 xmproc1 = dynamicLogWithPP $ xmobarPP
    { ppOutput = \x -> hPutStrLn xmproc0 x      -- xmobar on monitor 1
                    >> hPutStrLn xmproc1 x      -- xmobar on monitor 2

    , ppCurrent = xmobarColor "#98be65" ""                      -- Current workspace
        . wrap "<box type=Bottom width=2 mb=2 color=#98be65>" "</box>" . clickable
    , ppVisible = xmobarColor "#98be65" "" .clickable           -- Visible but not current workspace
    , ppHidden  = xmobarColor "#82aaff" "" . clickable          -- Hidden workspaces
    , ppHiddenNoWindows = xmobarColor "#c792ea" "" . clickable  -- Hidden workspaces (no windows)

    , ppTitle  = xmobarColor "#b3afc2" "" . shorten 60          -- Title of active window
    , ppSep    = "<fc=#666666> | </fc>"                         -- Separator character
    , ppUrgent = xmobarColor "#c45500" "" . wrap "!" "!"      -- Urgent workspace
    , ppExtras = [windowCount]                                  -- # of windows current workspace
    , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]                -- order of things in xmobar
    }


-------------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
main :: IO ()
main = do
    -- Launching 2 instances of xmobar on their respective monitors.
    xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
    xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
    -- Xmonad config definitions
    xmonad $ ewmh def
        { modMask               = myModMask
        , terminal              = myTerminal
        , workspaces            = myWorkspaces
        , startupHook           = myStartupHook
        , manageHook            = myManageHook <+> manageDocks
        , handleEventHook       = docksEventHook
        , layoutHook            = showWName' myShowWNameTheme $ myLayoutHook
        , borderWidth           = myBorderWidth
        , normalBorderColor     = myNormalBorderColor
        , focusedBorderColor    = myFocusedBorderColor
        , logHook               = myLogHook xmproc0 xmproc1
        } `additionalKeysP` myKeys


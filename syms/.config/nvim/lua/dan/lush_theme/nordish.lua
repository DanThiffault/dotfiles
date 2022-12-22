local lush = require('lush')
local hsl = lush.hsl

-- local C = require("dan.lush_theme.colors")
--
-- local tc = {
--   black = C.bg0,
--   red = C.red,
--   yellow = C.yellow,
--   green = C.green,
--   cyan = C.aqua,
--   blue = C.blue,
--   purple = C.purple,
--   white = C.fg,
-- }
--
-- vim.g.terminal_color_0 = tostring(tc.black)
-- vim.g.terminal_color_1 = tostring(tc.red)
-- vim.g.terminal_color_2 = tostring(tc.green)
-- vim.g.terminal_color_3 = tostring(tc.yellow)
-- vim.g.terminal_color_4 = tostring(tc.blue)
-- vim.g.terminal_color_5 = tostring(tc.purple)
-- vim.g.terminal_color_6 = tostring(tc.cyan)
-- vim.g.terminal_color_7 = tostring(tc.white)
-- vim.g.terminal_color_8 = tostring(tc.black)
-- vim.g.terminal_color_9 = tostring(tc.red)
-- vim.g.terminal_color_10 = tostring(tc.green)
-- vim.g.terminal_color_11 = tostring(tc.yellow)
-- vim.g.terminal_color_12 = tostring(tc.blue)
-- vim.g.terminal_color_13 = tostring(tc.purple)
-- vim.g.terminal_color_14 = tostring(tc.cyan)
-- vim.g.terminal_color_15 = tostring(tc.white)
-- vim.g.terminal_color_background = tostring(tc.black)
-- vim.g.terminal_color_foreground = tostring(tc.white)
--
-- vim.g.VM_Mono_hl = "Cursor"
-- vim.g.VM_Extend_hl = "Visual"
-- vim.g.VM_Cursor_hl = "Cursor"
-- vim.g.VM_Insert_hl = "Cursor"

-- LSP/Linters mistakenly show `undefined global` errors in the spec, they may
-- support an annotation like the following. Consult your server documentation.
---@diagnostic disable: undefined-global
local theme = lush(function(injected_functions)
  local sym = injected_functions.sym
  return {
    -- The following are the Neovim (as of 0.8.0-dev+100-g371dfb174) highlight
    -- groups, mostly used for styling UI elements.
    -- Comment them out and add your own properties to override the defaults.
    -- An empty definition `{}` will clear all styling, leaving elements looking
    -- like the 'Normal' group.
    -- To be able to link to a group, it must already be defined, so you may have
    -- to reorder items as you go.
    --
    -- See :h highlight-groups
    --
    ColorColumn    { bg = "#825243" }, -- Columns set with 'colorcolumn'
    Conceal        { fg = "#8DA2C0", gui = "bold, italic", cterm = "bold, italic"}, -- Placeholder characters substituted for concealed text (see 'conceallevel')
    Cursor         { fg = "#2F3541", bg = "#EEF1F5" }, -- Character under the cursor
    CurSearch      { bg = "#D1BACD", fg = "#2F3541", gui = "bold", cterm = "bold" }, -- Highlighting a search pattern under the cursor (see 'hlsearch')
    lCursor        { fg = "#2F3541", bg = "#8297B6" }, -- Character under the cursor when |language-mapping| is used (see 'cursor')
    -- CursorIM       { }, -- Like Cursor, but used when in IME mode |CursorIM|
    CursorColumn   { bg = "#353C49" }, -- Screen-column at the cursor, when 'cursorcolumn' is set.
    CursorLine     { CursorColumn }, -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
    Directory      { gui = "bold", cterm = "bold" }, -- Directory names (and other special names in listings)
    DiffAdd        { bg = "#3D4B2F" }, -- Diff mode: Added line |diff.txt|
    DiffChange     { bg = "#324B4B" }, -- Diff mode: Changed line |diff.txt|
    DiffDelete     { bg = "#663A3E" }, -- Diff mode: Deleted line |diff.txt|
    DiffText       { bg = "#476968", fg = "#EBEEF3" }, -- Diff mode: Changed text within a changed line |diff.txt|
    EndOfBuffer    { fg = "#606B81" }, -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
    TermCursor     { Cursor }, -- Cursor in a focused terminal
    TermCursorNC   {  bg = "#8297B6", fg = "#2F3541" }, -- Cursor in an unfocused terminal
    ErrorMsg       { fg = "#C1616A" }, -- Error messages on the command line
    VertSplit      { fg = "#69758C" }, -- Column separating vertically split windows
    Folded         { fg = "#A8B1C5", bg = "#464E5F" }, -- Line used for closed folds
    FoldColumn     { fg = "#69758C", gui = "bold", cterm = "bold" }, -- 'foldcolumn'
    SignColumn     { fg = "#69758C" }, -- Column where |signs| are displayed
    IncSearch      { fg = "#2F3541", bg = "#D1BACD", gui = "bold", cterm = "bold" }, -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
    -- Substitute     { }, -- |:substitute| replacement text highlighting
    LineNr         { SignColumn }, -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
    -- LineNrAbove    { }, -- Line number for when the 'relativenumber' option is set, above the cursor line
    -- LineNrBelow    { }, -- Line number for when the 'relativenumber' option is set, below the cursor line
    CursorLineNr   { fg = '#EBEEF3', gui = 'bold', cterm = 'bold' }, -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
    -- CursorLineFold { }, -- Like FoldColumn when 'cursorline' is set for the cursor line
    -- CursorLineSign { }, -- Like SignColumn when 'cursorline' is set for the cursor line
    MatchParen     { fg = "#EBEEF3", bg = "#84637E" }, -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
    -- ModeMsg        { }, -- 'showmode' message (e.g., "-- INSERT -- ")
    -- MsgArea        { }, -- Area for messages and cmdline
    -- MsgSeparator   { }, -- Separator for scrolled messages, `msgsep` flag of 'display'
    MoreMsg        { fg = "#A4BE8D", gui = "bold", cterm = "bold" }, -- |more-prompt|
    NonText        { fg = "#606B81" }, -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
    -- Normal         { fg = "#6B76AB", bg = "#171717" }, -- Normal text
    Normal         { fg = hsl(230, 28, 55), bg = hsl(0, 0, 0)}, -- Normal text
    -- NormalFloat    { fg = Normal.fg.lighten(10), bg = "#3F4756" }, -- Normal text in floating windows.
     NormalFloat    { fg = hsl(257, 100, 76),  bg = hsl(230, 28, 55).darken(70)}, -- Normal text in floating windows.
    FloatBorder    { bg = "#7E8CA8" }, -- Border of floating windows.
    -- FloatTitle     { }, -- Title of floating windows.
    -- NormalNC       { }, -- normal text in non-current windows
    Pmenu          { fg = "#EEEEEE", bg = Folded.bg}, -- Popup menu: Normal item.
    -- PmenuSel       { }, -- Popup menu: Selected item.
    -- PmenuKind      { }, -- Popup menu: Normal item "kind"
    -- PmenuKindSel   { }, -- Popup menu: Selected item "kind"
    -- PmenuExtra     { }, -- Popup menu: Normal item "extra text"
    -- PmenuExtraSel  { }, -- Popup menu: Selected item "extra text"
    -- PmenuSbar      { }, -- Popup menu: Scrollbar.
    -- PmenuThumb     { }, -- Popup menu: Thumb of the scrollbar.
    Question       { MoreMsg }, -- |hit-enter| prompt and yes/no questions
    -- QuickFixLine   { }, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
    Search         { MatchParen }, -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
    SpecialKey     { fg = "#606B81", gui = "italic", cterm = "italic" }, -- Unprintable characters: text displayed differently from what it really is. But not 'listchars' whitespace. |hl-Whitespace|
    SpellBad       { fg = "#B16B70", gui = "undercurl", cterm = "undercurl" }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
    SpellCap       { SpellBad }, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
    SpellLocal     { SpellBad}, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
    SpellRare      { SpellBad}, -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
    StatusLine     { fg = "#EBEEF3", bg = "#414959" }, -- Status line of current window
    StatusLineNC   { fg = "#F2F4F7", bg = "#39404E" }, -- Status lines of not-current windows. Note: If this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
    TabLine        { StatusLine }, -- Tab pages line, not active tab page label
    TabLineFill    { StatusLineNC }, -- Tab pages line, where there are no labels
    TabLineSel     { gui = "bold", cterm = "bold" }, -- Tab pages line, active tab page label
    Title          { fg = "#EBEEF3", gui = "bold", cterm = "bold" }, -- Titles for output from ":set all", ":autocmd" etc.
    Visual         { bg = "#545F70" }, -- Visual mode selection
    -- VisualNOS      { }, -- Visual mode selection when vim is "Not Owning the Selection".
    WarningMsg     { fg = "#CF866F" }, -- Warning messages
    Whitespace     { NonText }, -- "nbsp", "space", "tab" and "trail" in 'listchars'
    Winseparator   { VertSplit }, -- Separator between window splits. Inherts from |hl-VertSplit| by default, which it will replace eventually.
    WildMenu       { fg = "#2F3541", bg = "#B38DAC" }, -- Current match in 'wildmenu' completion
    -- WinBar         { }, -- Window bar of current window
    -- WinBarNC       { }, -- Window bar of not-current windows

    -- Common vim syntax groups used for all kinds of code and markup.
    -- Commented-out groups should chain up to their preferred (*) group
    -- by default.
    --
    -- See :h group-name
    --
    -- Uncomment and edit if you want more specific syntax highlighting.

    Comment        { fg = "#737C90", gui = "italic", cterm = "italic" }, -- Any comment

    Constant       { fg = "#9EAFC9", gui = "italic", cterm = "italic"  }, -- (*) Any constant
    -- String         { }, --   A string constant: "this is a string"
    -- Character      { }, --   A character constant: 'c', '\n'
    -- Number         { }, --   A number constant: 234, 0xff
    -- Boolean        { }, --   A boolean constant: TRUE, false
    -- Float          { }, --   A floating point constant: 2.3e10

    Identifier     { fg = "#BFCADB" }, -- (*) Any variable name
    Function       { fg = "#87BFCE" }, --   Function name (also: methods for classes)

    Statement      { fg = "#81A1C1" }, -- (*) Any statement
    -- Conditional    { }, --   if, then, else, endif, switch, etc.
    -- Repeat         { }, --   for, do, while, etc.
    -- Label          { }, --   case, default, etc.
    -- Operator       { }, --   "sizeof", "+", "*", etc.
    -- Keyword        { }, --   any other keyword
    -- Exception      { }, --   try, catch, throw

    PreProc        { Statement }, -- (*) Generic Preprocessor
    -- Include        { }, --   Preprocessor #include
    -- Define         { }, --   Preprocessor #define
    -- Macro          { }, --   Same as Define
    -- PreCondit      { }, --   Preprocessor #if, #else, #endif, etc.

    Type           { fg = "#5E81AB" }, -- (*) int, long, char, etc.
    -- StorageClass   { }, --   static, register, volatile, etc.
    -- Structure      { }, --   struct, union, enum, etc.
    -- Typedef        { }, --   A typedef

    Special        { fg = "#ABBAD0", gui = "bold", cterm = "bold" }, -- (*) Any special symbol
    -- SpecialChar    { }, --   Special character in a constant
    -- Tag            { }, --   You can use CTRL-] on this
    Delimiter      { fg = "#818EAB" }, --   Character that needs attention
    SpecialComment { fg = "#737C90" }, --   Special things inside a comment (e.g. '\n')
    Debug          { }, --   Debugging statements

    -- Underlined     { gui = "underline" }, -- Text that stands out, HTML links
    -- Ignore         { }, -- Left blank, hidden |hl-Ignore| (NOTE: May be invisible here in template)
    Error          { fg = "#C1616A" }, -- Any erroneous construct
    Todo           { gui = "bold", cterm = "bold" }, -- Anything that needs extra attention; mostly the keywords TODO FIXME and XXX

    -- These groups are for the native LSP client and diagnostic system. Some
    -- other LSP clients may use these groups, or use their own. Consult your
    -- LSP client's documentation.

    -- See :h lsp-highlight, some groups may not be listed, submit a PR fix to lush-template!
    --
    -- LspReferenceText            { } , -- Used for highlighting "text" references
    -- LspReferenceRead            { } , -- Used for highlighting "read" references
    -- LspReferenceWrite           { } , -- Used for highlighting "write" references
    -- LspCodeLens                 { } , -- Used to color the virtual text of the codelens. See |nvim_buf_set_extmark()|.
    -- LspCodeLensSeparator        { } , -- Used to color the seperator between two or more code lens.
    -- LspSignatureActiveParameter { } , -- Used to highlight the active parameter in the signature help. See |vim.lsp.handlers.signature_help()|.

    -- See :h diagnostic-highlights, some groups may not be listed, submit a PR fix to lush-template!
    --
    -- DiagnosticError            { } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    -- DiagnosticWarn             { } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    -- DiagnosticInfo             { } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    -- DiagnosticHint             { } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    -- DiagnosticOk               { } , -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
    -- DiagnosticVirtualTextError { } , -- Used for "Error" diagnostic virtual text.
    -- DiagnosticVirtualTextWarn  { } , -- Used for "Warn" diagnostic virtual text.
    -- DiagnosticVirtualTextInfo  { } , -- Used for "Info" diagnostic virtual text.
    -- DiagnosticVirtualTextHint  { } , -- Used for "Hint" diagnostic virtual text.
    -- DiagnosticVirtualTextOk    { } , -- Used for "Ok" diagnostic virtual text.
    -- DiagnosticUnderlineError   { } , -- Used to underline "Error" diagnostics.
    -- DiagnosticUnderlineWarn    { } , -- Used to underline "Warn" diagnostics.
    -- DiagnosticUnderlineInfo    { } , -- Used to underline "Info" diagnostics.
    -- DiagnosticUnderlineHint    { } , -- Used to underline "Hint" diagnostics.
    -- DiagnosticUnderlineOk      { } , -- Used to underline "Ok" diagnostics.
    -- DiagnosticFloatingError    { } , -- Used to color "Error" diagnostic messages in diagnostics float. See |vim.diagnostic.open_float()|
    -- DiagnosticFloatingWarn     { } , -- Used to color "Warn" diagnostic messages in diagnostics float.
    -- DiagnosticFloatingInfo     { } , -- Used to color "Info" diagnostic messages in diagnostics float.
    -- DiagnosticFloatingHint     { } , -- Used to color "Hint" diagnostic messages in diagnostics float.
    -- DiagnosticFloatingOk       { } , -- Used to color "Ok" diagnostic messages in diagnostics float.
    -- DiagnosticSignError        { } , -- Used for "Error" signs in sign column.
    -- DiagnosticSignWarn         { } , -- Used for "Warn" signs in sign column.
    -- DiagnosticSignInfo         { } , -- Used for "Info" signs in sign column.
    -- DiagnosticSignHint         { } , -- Used for "Hint" signs in sign column.
    -- DiagnosticSignOk           { } , -- Used for "Ok" signs in sign column.

    -- Tree-Sitter syntax groups.
    --
    -- See :h treesitter-highlight-groups, some groups may not be listed,
    -- submit a PR fix to lush-template!
    --
    -- Tree-Sitter groups are defined with an "@" symbol, which must be
    -- specially handled to be valid lua code, we do this via the special
    -- sym function. The following are all valid ways to call the sym function,
    -- for more details see https://www.lua.org/pil/5.html
    --
    -- sym("@text.literal")
    -- sym('@text.literal')
    -- sym"@text.literal"
    -- sym'@text.literal'
    --
    -- For more information see https://github.com/rktjmp/lush.nvim/issues/109

    -- sym"@text.literal"      { }, -- Comment
    -- sym"@text.reference"    { }, -- Identifier
    -- sym"@text.title"        { }, -- Title
    -- sym"@text.uri"          { }, -- Underlined
    -- sym"@text.underline"    { }, -- Underlined
    -- sym"@text.todo"         { }, -- Todo
    -- sym"@comment"           { }, -- Comment
    -- sym"@punctuation"       { }, -- Delimiter
    -- sym"@constant"          { }, -- Constant
    -- sym"@constant.builtin"  { }, -- Special
    -- sym"@constant.macro"    { }, -- Define
    -- sym"@define"            { }, -- Define
    -- sym"@macro"             { }, -- Macro
    -- sym"@string"            { }, -- String
    -- sym"@string.escape"     { }, -- SpecialChar
    -- sym"@string.special"    { }, -- SpecialChar
    -- sym"@character"         { }, -- Character
    -- sym"@character.special" { }, -- SpecialChar
    -- sym"@number"            { }, -- Number
    -- sym"@boolean"           { }, -- Boolean
    -- sym"@float"             { }, -- Float
    -- sym"@function"          { }, -- Function
    -- sym"@function.builtin"  { }, -- Special
    -- sym"@function.macro"    { }, -- Macro
    -- sym"@parameter"         { }, -- Identifier
    -- sym"@method"            { }, -- Function
    -- sym"@field"             { }, -- Identifier
    -- sym"@property"          { }, -- Identifier
    -- sym"@constructor"       { }, -- Special
    -- sym"@conditional"       { }, -- Conditional
    -- sym"@repeat"            { }, -- Repeat
    -- sym"@label"             { }, -- Label
    -- sym"@operator"          { }, -- Operator
    -- sym"@keyword"           { }, -- Keyword
    -- sym"@exception"         { }, -- Exception
    -- sym"@variable"          { }, -- Identifier
    -- sym"@type"              { }, -- Type
    -- sym"@type.definition"   { }, -- Typedef
    -- sym"@storageclass"      { }, -- StorageClass
    -- sym"@structure"         { }, -- Structure
    -- sym"@namespace"         { }, -- Identifier
    -- sym"@include"           { }, -- Include
    -- sym"@preproc"           { }, -- PreProc
    -- sym"@debug"             { }, -- Debug
    -- sym"@tag"               { }, -- Tag
}
end)

-- Return our parsed theme for extension or use elsewhere.
return theme

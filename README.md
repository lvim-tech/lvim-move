# lvim-move

Move lines and character selections in any direction in Neovim.

## Features

- Move lines **up/down** in normal and linewise visual mode
- Move character selections **up/down/left/right** in charwise visual mode
- Move lines **left/right** (indent/dedent) in normal and linewise visual mode
- Fold-aware — opens folds instead of moving when cursor is inside one
- Auto-indent after vertical moves (configurable)
- Custom highlight color while moving selections
- Column position preserved across vertical moves

## Installation

### 1. [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "lvim-tech/lvim-move",
    dependencies = {
        "lvim-tech/lvim-utils",
    },
    config = function()
        require("lvim-move").setup()
    end,
}
```

### 2. Native (vim.pack / packadd)

```lua
vim.pack.add({
	{ src = "https://github.com/lvim-tech/lvim-utils" },
	{ src = "https://github.com/lvim-tech/lvim-move" },
})

require("lvim-move").setup()
```

### 3. [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use({
	"lvim-tech/lvim-move",
	requires = {
		{ "lvim-tech/lvim-utils" },
	},
	config = function()
		require("lvim-move").setup()
	end,
})
```

## Setup

Call `setup()` optionally with a config table. All fields are optional.

```lua
require("lvim-move").setup({
	indent = true, -- auto-indent after moving lines up/down
	enable_move_hl = true, -- highlight selection while moving
	move_hl = "LvimMoveHL", -- highlight group name to use
	maps = {
		normal_down = "<A-j>",
		normal_up = "<A-k>",
		normal_left = "<A-h>",
		normal_right = "<A-l>",
		visual_down = "<A-j>",
		visual_up = "<A-k>",
		visual_left = "<A-h>",
		visual_right = "<A-l>",
	},
})
```

## Default Keymaps

| Mode   | Key     | Action                                   |
| ------ | ------- | ---------------------------------------- |
| Normal | `<A-j>` | Move line down                           |
| Normal | `<A-k>` | Move line up                             |
| Normal | `<A-h>` | Dedent line                              |
| Normal | `<A-l>` | Indent line                              |
| Visual | `<A-j>` | Move selection down                      |
| Visual | `<A-k>` | Move selection up                        |
| Visual | `<A-h>` | Dedent selection / move characters left  |
| Visual | `<A-l>` | Indent selection / move characters right |

Visual mode behaves differently depending on selection type:

- **Linewise (`V`)** — moves/indents whole lines
- **Charwise (`v`)** — moves the selected characters within the line (up/down/left/right)

## Highlight

The `LvimMoveHL` highlight group is used to color the selection while moving. Define it in your colorscheme or config:

```lua
vim.api.nvim_set_hl(0, "LvimMoveHL", { bg = "#3d5473" })
```

To disable the highlight entirely:

```lua
require("lvim-move").setup({ enable_move_hl = false })
```

## Disabling default keymaps

Pass empty strings to disable individual maps:

```lua
require("lvim-move").setup({
	maps = {
		normal_left = "",
		normal_right = "",
	},
})
```

Or set your own keys and create the mappings manually using the exposed actions:

```lua
vim.keymap.set("n", "<C-j>", function()
	require("lvim-move.actions").LvimMoveDownN()
end)
```

Available actions: `LvimMoveDownN`, `LvimMoveUpN`, `LvimMoveLeftN`, `LvimMoveRightN`, `LvimMoveDownV`, `LvimMoveUpV`, `LvimMoveLeftV`, `LvimMoveRightV`.

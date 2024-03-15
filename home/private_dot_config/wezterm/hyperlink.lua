--[[
Configure the hyperlink rules in WezTerm.
--]]

local M = {}

--- Configure the font used in the terminal.
---@param config table The terminal configuration to modify.
M.apply = function(config)
  config.hyperlink_rules = {
    -- Matches: a URL in parens: (URL)
    { regex = '\\((\\w+://\\S+)\\)', format = '$1', highlight = 1 },
    -- Matches: a URL in brackets: [URL]
    { regex = '\\[(\\w+://\\S+)\\]', format = '$1', highlight = 1 },
    -- Matches: a URL in curly braces: {URL}
    { regex = '\\{(\\w+://\\S+)\\}', format = '$1', highlight = 1 },
    -- Matches: a URL in angle brackets: <URL>
    { regex = '<(\\w+://\\S+)>', format = '$1', highlight = 1 },
    -- Then handle URLs not wrapped in brackets
    { regex = '[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)', format = '$1', highlight = 1 },
    -- implicit mailto link
    { regex = '\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b', format = 'mailto:$0' },
  }
end

return M

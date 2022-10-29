-- Define an abbreviation
local function abbrev(mode, input, result, reabbrev)
  reabbrev = reabbrev or false
  local command
  if reabbrev then
    command = mode .. "abbrev"
  else
    command = mode .. "noreabbrev"
  end
  vim.cmd(command .. " " .. input .. " " .. result)
end

-- In case I have caps on (don't judge me for using caps)
abbrev("c", "Wq", "wq")
abbrev("c", "wQ", "wq")
abbrev("c", "WQ", "wq")
abbrev("c", "WQ!", "wq")
abbrev("c", "wQ!", "wq")
abbrev("c", "Wq!", "wq")
abbrev("c", "W", "w")
abbrev("c", "W!", "w!")
abbrev("c", "Q", "q!")
abbrev("c", "Q!", "q!")
abbrev("c", "Qall", "qall")
abbrev("c", "Qall!", "qall")
abbrev("c", "QALL", "qall")
abbrev("c", "QALL!", "qall")

-- Save file with sudo
abbrev("c", "w!!", "w !sudo tee > /dev/null %")

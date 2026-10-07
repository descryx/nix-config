local M = {}

function M.setup()
  vim.diagnostic.config({
    virtual_text = {
      prefix = "●",
      spacing = 2,
    },
--    virtual_text = false,  --  inline text
    signs = true,         --  E/W in gutter
    underline = true,      -- optional (keeps subtle underline)
    update_in_insert = false,
    severity_sort = true,
  })

  local signs = {
    Error = "",
    Warn = "",
    Hint = "󰠠",
    Info = "",
  }

  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end
end

return M

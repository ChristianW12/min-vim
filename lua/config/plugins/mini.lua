-- lua/config/plugins/mini.lua
-- Zentrale Konfiguration für alle mini.nvim Module

-- 1. mini.surround (Ersatz für nvim-surround)
-- Standard Tastenbelegungen:
-- - sa (hinzufügen)
-- - sd (löschen)
-- - sr (ersetzen)
require("mini.surround").setup({})

-- 2. mini.pairs (Ersatz für nvim-autopairs)
-- Automatisches Schließen von (), [], {}, '', "", ``
require("mini.pairs").setup({})

-- 3. mini.splitjoin (Ersatz für treesj)
-- Standard Tastenbelegung:
-- - gS (Toggle: umbrechen/zusammenfügen)
require("mini.splitjoin").setup({})

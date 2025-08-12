-- ~/.config/nvim/lua/rest_viewer/init.lua
local M = {}
local curl = require("plenary.curl")

-- Função para abrir popup
local function open_popup(content)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})
end

-- Função principal: faz chamada REST e exibe, com headers opcionais
-- headers deve ser uma tabela Lua, ex: { Authorization = "Basic xyz", ["Content-Type"] = "application/json" }
M.get = function(url, headers)
	headers = headers or {} -- se não passar, usa vazio

	curl.get(url, {
		headers = headers,
		callback = vim.schedule_wrap(function(response)
			if response.status ~= 200 then
				open_popup({ "Erro: " .. response.status, response.body })
			else
				local lines = {}
				for s in response.body:gmatch("[^\r\n]+") do
					table.insert(lines, s)
				end
				open_popup(lines)
			end
		end),
	})
end

return M

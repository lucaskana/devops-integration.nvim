-- ~/.config/nvim/lua/rest_viewer/init.lua
local M = {}
local curl = require("plenary.curl")

-- Função para abrir popup
local function open_popup(content)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(#content + 2) -- altura dinâmica conforme conteúdo
	if height > math.floor(vim.o.lines * 0.8) then
		height = math.floor(vim.o.lines * 0.8)
	end

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

-- Função para extrair e formatar o campo "values" do JSON
local function extract_values(json_str)
	local ok, data = pcall(vim.fn.json_decode, json_str)
	if not ok or type(data) ~= "table" then
		return { "Erro ao decodificar JSON ou formato inválido" }
	end

	-- Tenta pegar o campo 'values' na raiz do objeto
	local values = data["value"]
	if not values then
		return { "'values' não encontrado no JSON" }
	end

	-- Formata os valores como linhas de string
	local lines = { "Campo 'value':" }
	for i, v in ipairs(values) do
		table.insert(lines, string.format("%d: %s", i, tostring(v)))
	end

	return lines
end

-- Função principal: faz chamada REST e exibe campo 'values' ou erro
-- headers deve ser uma tabela Lua, ex: { Authorization = "Basic xyz", ["Content-Type"] = "application/json" }
M.get = function(url, headers)
	headers = headers or {}

	curl.get(url, {
		headers = headers,
		callback = vim.schedule_wrap(function(response)
			if response.status ~= 200 then
				open_popup({ "Erro: " .. response.status, response.body })
			else
				local content_lines = extract_values(response.body)
				open_popup(content_lines)
			end
		end),
	})
end

return M

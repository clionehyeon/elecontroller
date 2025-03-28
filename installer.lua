local files = {
    {url = "https://example.com/script1.lua", name = "script1.lua"},
    {url = "https://example.com/script2.lua", name = "script2.lua"},
    {url = "https://example.com/script3.lua", name = "script3.lua"}
}

for _, file in ipairs(files) do
    print("Downloading " .. file.name .. "...")
    shell.run("wget", file.url, file.name)
end

-- Basalt 다운로드
shell.run("wget","run","https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua","-r")

print("Installation complete!")
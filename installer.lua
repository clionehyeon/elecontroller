local files = {
    {url = "https://raw.githubusercontent.com/clionehyeon/elecontroller/refs/heads/main/elecontroller.lua", name = "elecontroller.lua"},
    {url = "https://raw.githubusercontent.com/clionehyeon/elecontroller/refs/heads/main/queue.lua", name = "queue.lua"},
    {url = "https://raw.githubusercontent.com/clionehyeon/elecontroller/refs/heads/main/sequence.lua", name = "sequence.lua"},
    {url = "https://raw.githubusercontent.com/clionehyeon/elecontroller/refs/heads/main/task.lua", name = "task.lua"}
}

for _, file in ipairs(files) do
    print("Downloading " .. file.name .. "...")
    shell.run("wget", file.url, file.name)
end

-- Basalt 다운로드
shell.run("wget","run","https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua","-r")

print("Installation complete!")
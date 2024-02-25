import os
import re
import requests

# GitHub 项目信息
owner = "Loyalsoldier"
repo = "clash-rules"
blacklist = ["applications.txt"]  # 黑名单列表，不转化的文件名

# 获取 GitHub 项目的最新 release 信息
url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
response = requests.get(url)
if response.status_code == 200:
    release_info = response.json()
    assets = release_info['assets']

    # 创建一个名为"rules/text"的文件夹
    if not os.path.exists("rules/text"):
        os.makedirs("rules/text")

    # 遍历每个文件
    for asset in assets:
        download_url = asset['browser_download_url']
        filename = asset['name']

        if filename in blacklist:
            print(f"文件 {filename} 在黑名单中，跳过转化")
            continue

        response = requests.get(download_url)
        online_file_content = response.text

        # 删除开头的'payload:'
        online_file_content = re.sub(r'^payload:\n', '', online_file_content)

        # 匹配''之间的内容，去掉开头的'+.'
        pattern = re.compile(r"'(?:\+\.)?(.*?)'")
        converted_content = '\n'.join(re.findall(pattern, online_file_content))

        # 保存为本地文件，保存到"rules/text"文件夹中
        with open(os.path.join("rules/text", filename), 'w') as file:
            file.write(converted_content)

        print(f"已将转换内容保存到文件: {filename}")
else:
    print("无法获取 GitHub 最新 release 信息")

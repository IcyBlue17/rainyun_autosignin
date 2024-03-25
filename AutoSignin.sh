#!/bin/bash

echo "RainYun AutoSign Script By IcyMichiko"
echo "------------------------"
echo "1.增加一个自动签到"
echo "2.卸载全部服务"
echo "------------------------"

read -p "请输入你的选择（1或2）: " choice

if [ "$choice" == "1" ]; then
    read -p "请输入你的雨云API密钥: " ryapikey

    response=$(curl -s -H "x-api-key: $ryapikey" https://api.v2.rainyun.com/user/)

    code=$(echo "$response" | jq -r '.code')
    if [ "$code" -eq 200 ]; then
        name=$(echo "$response" | jq -r '.data.Name')
        email=$(echo "$response" | jq -r '.data.Email')
        last=$(echo "$response" | jq -r '.data.LastLoginArea')

        echo "请确认你的账户信息："
        echo "昵称: $name"
        echo "邮箱: $email"
        echo "上次登陆地点: $last"
        echo "若准确无误请按任意键继续."

        read -n 1 -s -r -p "按任意键继续..."

        script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

        echo "#!/bin/bash" > "${script_path}/ryautosign_${name}.sh"
        echo "" >> "${script_path}/ryautosign_${name}.sh"
        echo "ryapikey=\"$ryapikey\"" >> "${script_path}/ryautosign_${name}.sh"
        echo "" >> "${script_path}/ryautosign_${name}.sh"
        echo 'response=$(curl -s -X POST \' >> "${script_path}/ryautosign_${name}.sh"
        echo '  -H "Content-Type: application/json" \' >> "${script_path}/ryautosign_${name}.sh"
        echo '  -H "x-api-key: $ryapikey" \' >> "${script_path}/ryautosign_${name}.sh"
        echo '  -d '\''{"task_name": "每日签到"}'\'' \' >> "${script_path}/ryautosign_${name}.sh"
        echo '  https://api.v2.rainyun.com/user/reward/tasks)' >> "${script_path}/ryautosign_${name}.sh"
        echo "" >> "${script_path}/ryautosign_${name}.sh"
        echo 'echo "自动签到脚本执行结果：$response"' >> "${script_path}/ryautosign_${name}.sh"

        chmod +x "${script_path}/ryautosign_${name}.sh"

        (crontab -l 2>/dev/null; echo "30 8 * * * ${script_path}/ryautosign_${name}.sh") | crontab -

        echo -e "\e[1;32m计划任务添加成功，将在每天早上八点半执行\e[0m"
    else
        echo -e "\e[1;31mAPI调用错误，请检查雨云API是否正常或API密钥是否正确\e[0m"
    fi
elif [ "$choice" == "2" ]; then
    echo "卸载全部服务的代码..."
else
    echo "无效的选择"
fi

#########################################################################
# File Name: update_webhoook.sh
# Author: Charles
# Created Time: 2025-07-09 15:45:07
#########################################################################


#!/bin/bash
set -u
set -e

# GitLab 配置
GITLAB_URL="https://xxx.link"  # GitLab 地址
GITLAB_TOKEN="xxx" # 具有 API 权限的 Token
OLD_HOOK_URL="https://xxx//generic-webhook-trigger/invoke"  # 要替换的旧 Webhook URL
NEW_HOOK_URL="http://xxx/generic-webhook-trigger/invoke?token=xxx"  # 新的 Webhook URL

# 可选：只处理特定项目（按名称过滤，如 "my-project-*"）
PROJECT_NAME_FILTER=""

# 获取所有项目列表（分页查询）
get_all_projects() {
    PAGE=1
    PROJECTS=""
    while true; do
        RESPONSE=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
            "$GITLAB_URL/api/v4/projects?per_page=100&page=$PAGE")
        if [ -z "$RESPONSE" ] || [ "$RESPONSE" = "[]" ]; then
            break
        fi
        PROJECTS+="$RESPONSE"
        ((PAGE++))
    done
    echo "$PROJECTS" | jq -c '.[]'
}

# 更新符合条件的 Webhook
update_hooks() {
    PROJECT_ID="$1"
    PROJECT_NAME="$2"
    HOOKS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "$GITLAB_URL/api/v4/projects/$PROJECT_ID/hooks")

    echo "检查项目: $PROJECT_NAME (ID: $PROJECT_ID)"
    echo "$HOOKS" | jq -c '.[]' | while read -r HOOK; do
        HOOK_ID=$(echo "$HOOK" | jq -r '.id')
        HOOK_URL=$(echo "$HOOK" | jq -r '.url')

        if [[ "$HOOK_URL" == "$OLD_HOOK_URL" ]]; then
            echo "发现匹配的 Webhook: ID=$HOOK_ID, URL=$HOOK_URL"
            echo "更新为: $NEW_HOOK_URL"

            # 发送 API 请求更新 Webhook
            curl --request PUT --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                --header "Content-Type: application/json" \
                --data "{
                    \"url\": \"$NEW_HOOK_URL\",
                    \"push_events\": true,
                    \"tag_push_events\": true,
                    \"enable_ssl_verification\": false
                }" \
                "$GITLAB_URL/api/v4/projects/$PROJECT_ID/hooks/$HOOK_ID"

            echo "Webhook 更新成功！"
        fi
    done
}

# 主逻辑
echo "开始批量更新 GitLab Webhook..."
get_all_projects | while read -r PROJECT; do
    PROJECT_ID=$(echo "$PROJECT" | jq -r '.id')
    PROJECT_NAME=$(echo "$PROJECT" | jq -r '.name')
    PROJECT_PATH=$(echo "$PROJECT" | jq -r '.path_with_namespace')

    # 按项目名过滤（如果启用）
    if [[ -n "$PROJECT_NAME_FILTER" && ! "$PROJECT_PATH" =~ $PROJECT_NAME_FILTER ]]; then
        continue
    fi

    update_hooks "$PROJECT_ID" "$PROJECT_PATH"
done

echo "批量更新完成！"

#########################################################################
# File Name: k8s_update_deploy.sh
# Author: Charles
# Created Time: 2025-10-30 18:13:21
#########################################################################

#!/bin/bash
set -e
#set -x

# 可配置变量（请根据您的实际需求修改）
DEPLOYMENT_NAME=$RELEASE_NAME
NAMESPACE=$KUBE_NAMESPACE
MAX_WAIT_SECONDS=300       # 等待就绪的最大秒数（5分钟）
CHECK_INTERVAL=5           # 检查状态的间隔秒数
# CI_APPLICATION_REPOSITORY
# CI_APPLICATION_TAG

echo "开始更新 Deployment: $DEPLOYMENT_NAME, 镜像: $CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"

# 步骤 1: 更新镜像
echo "步骤 1: 更新 Deployment 的镜像..."
kubectl set image deployment/$DEPLOYMENT_NAME $RELEASE_NAME=$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG -n $NAMESPACE
echo "✅ 镜像更新命令已执行"

# 步骤 2: 监控滚动更新状态
echo "步骤 2: 监控滚动更新进程..."
kubectl rollout status deployment/$DEPLOYMENT_NAME -n $NAMESPACE --timeout=${MAX_WAIT_SECONDS}s

if [ $? -eq 0 ]; then
    echo "✅ 滚动更新成功完成"
else
    echo "❌ 滚动更新失败或超时（等待超过 ${MAX_WAIT_SECONDS} 秒）"
    echo "--- 开始故障诊断 ---"

    # 显示 Deployment 详细状态
    echo "Deployment 状态:"
    kubectl describe deployment/$DEPLOYMENT_NAME -n $NAMESPACE

    # 显示相关 Pod 的状态和事件
    echo "关联 Pod 的状态:"
    kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME

    echo "最近 Pod 事件:"
    kubectl get events -n $NAMESPACE --field-selector involvedObject.name=$DEPLOYMENT_NAME --sort-by='.lastTimestamp'

    exit 1
fi

# 步骤 3: 最终就绪状态验证
echo "步骤 3: 进行最终就绪状态验证..."
ALL_READY=$(kubectl get deployment/$DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
DESIRED_REPLICAS=$(kubectl get deployment/$DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.status.replicas}')

if [ "$ALL_READY" == "$DESIRED_REPLICAS" ]; then
    echo "✅ 成功！所有 $DESIRED_REPLICAS 个 Pod 副本均已就绪。"
    echo "✅ 应用更新已完成且运行正常。"
else
    echo "❌ 就绪副本数 ($ALL_READY) 与期望副本数 ($DESIRED_REPLICAS) 不符。"
    echo "请检查: kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME"
    exit 1
fi

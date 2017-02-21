server=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "aws_kubernetes")].cluster.server}')
user=$(kubectl config view -o jsonpath='{.users[?(@.name == "aws_kubernetes-basic-auth")].user.username}')
pass=$(kubectl config view -o jsonpath='{.users[?(@.name == "aws_kubernetes-basic-auth")].user.password}')
elastic_path='api/v1/proxy/namespaces/kube-system/services/elasticsearch-logging'
json=$(curl --insecure -u $user:$pass "$server/$elastic_path/_cluster/health?level=indices")
indices=$(echo $json | jq .indices | jq 'keys')
for indice in $(echo $indices | jq -r '.[]'); do
   curl --insecure -u $user:$pass -XPUT "$server/$elastic_path/$indice/_settings" -d '{"index":{"auto_expand_replicas":"0-all"}}'
done
